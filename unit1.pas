unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  DB, SQLDB, FBConnection;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    DBGrid1: TDBGrid;
    DataSource1: TDataSource;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FBConnection: TFBConnection;
    SQLTransaction: TSQLTransaction;
    SQLQuery: TSQLQuery;
    procedure ConnectToDatabase;
    procedure LoadPassesData;
    procedure InitializeComponents;
    procedure SafeShowRecordCount;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.InitializeComponents;
begin

  FBConnection := TFBConnection.Create(Self);
  SQLTransaction := TSQLTransaction.Create(Self);
  SQLQuery := TSQLQuery.Create(Self);

  FBConnection.HostName := 'localhost';
  FBConnection.DatabaseName := 'C:\Users\fosius\Documents\databases\firebird\PASSES.fdb';
  FBConnection.UserName := 'SYSDBA';
  FBConnection.Password := 'masterkey';
  FBConnection.Charset := 'UTF8';

  SQLTransaction.DataBase := FBConnection;
  FBConnection.Transaction := SQLTransaction;

  SQLQuery.DataBase := FBConnection;
  SQLQuery.Transaction := SQLTransaction;

  DataSource1.DataSet := SQLQuery;
  DBGrid1.DataSource := DataSource1;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitializeComponents;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  if Assigned(SQLQuery) then
  begin
    if SQLQuery.Active then SQLQuery.Close;
    FreeAndNil(SQLQuery);
  end;

  if Assigned(SQLTransaction) then
    FreeAndNil(SQLTransaction);

  if Assigned(FBConnection) then
  begin
    if FBConnection.Connected then FBConnection.Connected := False;
    FreeAndNil(FBConnection);
  end;
end;

procedure TForm1.ConnectToDatabase;
begin
  try
    if not FBConnection.Connected then
    begin
      FBConnection.Connected := True;
      ShowMessage('Подключение к Firebird успешно установлено');
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Ошибка подключения: ' + E.Message);
      if Pos('I/O error', E.Message) > 0 then
        ShowMessage('Проверьте путь к файлу базы данных');
      if Pos('user name', E.Message) > 0 then
        ShowMessage('Проверьте логин и пароль');
      if Pos('file not found', E.Message) > 0 then
        ShowMessage('Файл базы данных не найден');
    end;
  end;
end;

procedure TForm1.SafeShowRecordCount;
begin
  try
    if SQLQuery.Active then
    begin
      SQLQuery.Last;
      SQLQuery.First;
      ShowMessage('Загружено записей: ' + IntToStr(SQLQuery.RecordCount));
    end;
  except
    on E: Exception do
      ShowMessage('Ошибка при подсчете записей: ' + E.Message);
  end;
end;

procedure TForm1.LoadPassesData;
begin
  if not FBConnection.Connected then
  begin
    ShowMessage('Сначала подключитесь к базе данных');
    Exit;
  end;

  try
    SQLQuery.Close;
    SQLQuery.SQL.Text := 'SELECT * FROM PASS';
    SQLQuery.Open;

    SafeShowRecordCount;
  except
    on E: Exception do
    begin
      ShowMessage('Ошибка загрузки данных: ' + E.Message);
      if Pos('Table unknown', E.Message) > 0 then
        ShowMessage('Таблица PASS не существует в базе данных');
      if Pos('not found', E.Message) > 0 then
        ShowMessage('База данных или таблица не найдены');
    end;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  ConnectToDatabase;
  LoadPassesData;
end;

end.
