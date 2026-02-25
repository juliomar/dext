{***************************************************************************}
{                                                                           }
{           Dext Framework                                                  }
{                                                                           }
{           Copyright (c) 2024 Dext Framework                               }
{                                                                           }
{           https://github.com/dext-framework/dext                          }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}

unit Dext.Collections.Stack;

interface

uses
  System.SysUtils,
  System.TypInfo,
  Dext.Collections.Base,
  Dext.Collections.Raw,
  Dext.Collections;

type
  /// <summary>Stack implementation backed by TRawList</summary>
  TStack<T> = class(TInterfacedObject, IStack<T>, IEnumerable<T>)
  private
    FCore: TRawList;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Push(const Value: T);
    function Pop: T;
    function Peek: T;
    function TryPop(out Value: T): Boolean;
    function TryPeek(out Value: T): Boolean;
    procedure Clear;
    function Contains(const Value: T): Boolean;
    function ToArray: TArray<T>;

    function GetEnumerator: IEnumerator<T>;
  end;

  /// <summary>Simple LIFO enumerator</summary>
  TStackEnumerator<T> = class(TInterfacedObject, IEnumerator<T>)
  private
    FCore: TRawList;
    FIndex: Integer;
  public
    constructor Create(ACore: TRawList);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TStack<T> }

constructor TStack<T>.Create;
begin
  inherited Create;
  FCore := TRawList.Create(SizeOf(T), TypeInfo(T));
end;

destructor TStack<T>.Destroy;
begin
  FCore.Free;
  inherited;
end;

procedure TStack<T>.Clear;
begin
  FCore.Clear;
end;

function TStack<T>.Contains(const Value: T): Boolean;
var
  I: Integer;
begin
  // Linear search from top to bottom
  for I := FCore.Count - 1 downto 0 do
    if CompareMem(FCore.GetItemPtr(I), @Value, SizeOf(T)) then
      Exit(True);
  Result := False;
end;

function TStack<T>.GetCount: Integer;
begin
  Result := FCore.Count;
end;

function TStack<T>.GetEnumerator: IEnumerator<T>;
begin
  Result := TStackEnumerator<T>.Create(FCore);
end;

function TStack<T>.Peek: T;
begin
  if FCore.Count = 0 then
    raise EListError.Create('Stack is empty');
  FCore.GetRawItem(FCore.Count - 1, @Result);
end;

function TStack<T>.Pop: T;
begin
  Result := Peek;
  FCore.DeleteRaw(FCore.Count - 1);
end;

procedure TStack<T>.Push(const Value: T);
begin
  FCore.AddRaw(@Value);
end;

function TStack<T>.ToArray: TArray<T>;
var
  I: Integer;
begin
  SetLength(Result, FCore.Count);
  for I := 0 to FCore.Count - 1 do
    FCore.GetRawItem(FCore.Count - 1 - I, @Result[I]); // Stack order: top first
end;

function TStack<T>.TryPeek(out Value: T): Boolean;
begin
  if FCore.Count = 0 then
  begin
    Value := Default(T);
    Exit(False);
  end;
  FCore.GetRawItem(FCore.Count - 1, @Value);
  Result := True;
end;

function TStack<T>.TryPop(out Value: T): Boolean;
begin
  if TryPeek(Value) then
  begin
    FCore.DeleteRaw(FCore.Count - 1);
    Exit(True);
  end;
  Result := False;
end;

{ TStackEnumerator<T> }

constructor TStackEnumerator<T>.Create(ACore: TRawList);
begin
  inherited Create;
  FCore := ACore;
  FIndex := FCore.Count;
end;

function TStackEnumerator<T>.GetCurrent: T;
begin
  FCore.GetRawItem(FIndex, @Result);
end;

function TStackEnumerator<T>.MoveNext: Boolean;
begin
  Dec(FIndex);
  Result := FIndex >= 0;
end;

procedure TStackEnumerator<T>.Reset;
begin
  FIndex := FCore.Count;
end;

end.
