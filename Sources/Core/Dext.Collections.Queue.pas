{***************************************************************************}
{                                                                           }
{           Dext Framework                                                  }
{                                                                           }
{           Copyright (c) 2024 Dext Framework                               }
{                                                                           }
{           https://github.com/dext-framework/dext                          }
{                                                                           }
{***************************************************************************}

unit Dext.Collections.Queue;

interface

uses
  System.SysUtils,
  System.TypInfo,
  Dext.Collections.Base,
  Dext.Collections.Memory,
  Dext.Collections;

type
  /// <summary>Queue implementation using a circular buffer for O(1) ops</summary>
  TQueue<T> = class(TInterfacedObject, IQueue<T>, IEnumerable<T>)
  private
    FData: PByte;
    FCount: Integer;
    FCapacity: Integer;
    FHead: Integer;
    FTail: Integer;
    FElementSize: Integer;
    FTypeInfo: PTypeInfo;
    FIsManaged: Boolean;

    procedure SetCapacity(ACapacity: Integer);
    procedure Grow;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Enqueue(const Value: T);
    function Dequeue: T;
    function Peek: T;
    function TryDequeue(out Value: T): Boolean;
    function TryPeek(out Value: T): Boolean;
    procedure Clear;
    function Contains(const Value: T): Boolean;
    function ToArray: TArray<T>;

    function GetEnumerator: IEnumerator<T>;
    property Count: Integer read GetCount;
  end;

  /// <summary>FIFO enumerator for circular buffer</summary>
  TQueueEnumerator<T> = class(TInterfacedObject, IEnumerator<T>)
  private
    FQueue: TQueue<T>;
    FIndex: Integer; // 0..Count-1
    FCurrent: T;
  public
    constructor Create(AQueue: TQueue<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

const
  INITIAL_CAPACITY = 4;

{ TQueue<T> }

constructor TQueue<T>.Create;
begin
  inherited Create;
  FElementSize := SizeOf(T);
  FTypeInfo := TypeInfo(T);
  FIsManaged := IsManagedType(FTypeInfo);
  FData := nil;
  FCount := 0;
  FCapacity := 0;
  FHead := 0;
  FTail := 0;
end;

destructor TQueue<T>.Destroy;
begin
  Clear;
  if FData <> nil then
    FreeMem(FData);
  inherited;
end;

procedure TQueue<T>.Clear;
var
  I, Idx: Integer;
begin
  if (FCount > 0) and FIsManaged then
  begin
    for I := 0 to FCount - 1 do
    begin
      Idx := (FHead + I) mod FCapacity;
      RawFinalizeElement(FData + (Idx * FElementSize), FElementSize, FTypeInfo);
    end;
  end;
  
  if FCapacity > 0 then
    FillChar(FData^, FCapacity * FElementSize, 0);
    
  FCount := 0;
  FHead := 0;
  FTail := 0;
end;

function TQueue<T>.Contains(const Value: T): Boolean;
var
  I, Idx: Integer;
begin
  for I := 0 to FCount - 1 do
  begin
    Idx := (FHead + I) mod FCapacity;
    if CompareMem(FData + (Idx * FElementSize), @Value, FElementSize) then
      Exit(True);
  end;
  Result := False;
end;

function TQueue<T>.Dequeue: T;
begin
  if not TryDequeue(Result) then
    raise EListError.Create('Queue is empty');
end;

procedure TQueue<T>.Enqueue(const Value: T);
begin
  if FCount = FCapacity then
    Grow;
    
  RawCopyElement(FData + (FTail * FElementSize), @Value, FElementSize, FTypeInfo);
  FTail := (FTail + 1) mod FCapacity;
  Inc(FCount);
end;

function TQueue<T>.GetCount: Integer;
begin
  Result := FCount;
end;

function TQueue<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TQueueEnumerator<T>.Create(Self);
end;

procedure TQueue<T>.Grow;
var
  NewCap: Integer;
begin
  if FCapacity = 0 then
    NewCap := INITIAL_CAPACITY
  else
    NewCap := FCapacity * 2;
  SetCapacity(NewCap);
end;

function TQueue<T>.Peek: T;
begin
  if not TryPeek(Result) then
    raise EListError.Create('Queue is empty');
end;

procedure TQueue<T>.SetCapacity(ACapacity: Integer);
var
  NewData: PByte;
  I, Idx: Integer;
begin
  if ACapacity < FCount then
    ACapacity := FCount;
    
  if ACapacity = FCapacity then
    Exit;
    
  GetMem(NewData, ACapacity * FElementSize);
  FillChar(NewData^, ACapacity * FElementSize, 0);
  
  if FCount > 0 then
  begin
    // Copy elements in order to the beginning of the new buffer
    for I := 0 to FCount - 1 do
    begin
      Idx := (FHead + I) mod FCapacity;
      // We move raw bytes because we are reallocating the whole buffer
      System.Move((FData + (Idx * FElementSize))^, (NewData + (I * FElementSize))^, FElementSize);
    end;
  end;
  
  if FData <> nil then
    FreeMem(FData);
    
  FData := NewData;
  FCapacity := ACapacity;
  FHead := 0;
  FTail := FCount;
  if (FTail = FCapacity) and (FCapacity > 0) then
    FTail := 0;
end;

function TQueue<T>.ToArray: TArray<T>;
var
  I, Idx: Integer;
begin
  SetLength(Result, FCount);
  for I := 0 to FCount - 1 do
  begin
    Idx := (FHead + I) mod FCapacity;
    RawCopyElement(@Result[I], FData + (Idx * FElementSize), FElementSize, FTypeInfo);
  end;
end;

function TQueue<T>.TryDequeue(out Value: T): Boolean;
begin
  if FCount = 0 then
  begin
    Value := Default(T);
    Exit(False);
  end;
  
  RawCopyElement(@Value, FData + (FHead * FElementSize), FElementSize, FTypeInfo);
  // We need to zero the memory in the buffer so it doesn't hold a reference.
  FillChar((FData + (FHead * FElementSize))^, FElementSize, 0);
  
  FHead := (FHead + 1) mod FCapacity;
  Dec(FCount);
  Result := True;
end;

function TQueue<T>.TryPeek(out Value: T): Boolean;
begin
  if FCount = 0 then
  begin
    Value := Default(T);
    Exit(False);
  end;
  RawCopyElement(@Value, FData + (FHead * FElementSize), FElementSize, FTypeInfo);
  Result := True;
end;

{ TQueueEnumerator<T> }

constructor TQueueEnumerator<T>.Create(AQueue: TQueue<T>);
begin
  inherited Create;
  FQueue := AQueue;
  FIndex := -1;
end;

function TQueueEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TQueueEnumerator<T>.MoveNext: Boolean;
var
  RealIdx: Integer;
begin
  Inc(FIndex);
  if FIndex < FQueue.FCount then
  begin
    RealIdx := (FQueue.FHead + FIndex) mod FQueue.FCapacity;
    RawCopyElement(@FCurrent, FQueue.FData + (RealIdx * FQueue.FElementSize), FQueue.FElementSize, FQueue.FTypeInfo);
    Exit(True);
  end;
  Result := False;
end;

procedure TQueueEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.
