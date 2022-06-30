program Xonix;
Uses GraphABC, Events,ABCButtons;
type
  tsprite = record
    x, y, dx, dy: Integer;
  end;
const
  n = 60; //ширина игрового поля
  m = 40; //высота игрового поля
  p = 75; //процент заполнения поля, после которого игра выиграна
  label 1;
  label 2;
Var
  a: array[1..n, 1..m] of Integer; //игровое поле
  player: tsprite; //положение игрока
  e:integer;//количество врагов
  enemys: array[1..5] of tsprite; //положение врага
  theEnd := False;//флаг выхода из цикла
  key:Integer;//нажатая клавиша
  fl:Boolean;//флаг окончания игры
  st:String;//Результат игры
  ch:String;
  q:string;
  z:text;
  pr:integer;
  w:string;
  err:integer;

procedure KeyDown(key : Integer) := theEnd := True;

Procedure Zast;//Заставка
begin
 SetFontSize(20);
 TextOut(150,400,'Нажмите любую клавишу');
 SetFontSize(50);
 SetFontStyle(fsBold);
 repeat
  SetFontColor(clBlue);
  TextOut(200,150,'XONIX');
  Sleep(1000);
  SetFontColor(clGreen);
  TextOut(200,150,'XONIX');
  Sleep(1000);
  SetFontColor(clRed);
  TextOut(200,150,'XONIX');
  Sleep(100);
 until theEnd;
 
end;

procedure clear_occupied(x, y: Integer); //рекурсивная процедура
//очищает занятые врагами участки от заполнения
//в качестве стартовых получает координаты врага
//получает координаты ячейки в массиве а вокруг которых нужно поменять 2 на 0
//если встречает двойку заменяет ее нулем
//и вызывает сама себя с координатами очищенной ячейки
begin
  if a[x + 1, y] = 2 then
    //если ниже ячейки в полученных процедурой координатах двойка
  begin
    a[x + 1, y] := 0; //меняем ее на 0
    clear_occupied(x + 1, y);
      //вызываем процедуру передав ей координаты очищенной ячейки
  end;
  if a[x - 1, y] = 2 then
  begin
    a[x - 1, y] := 0;
    clear_occupied(x - 1, y);
  end;
  if a[x, y + 1] = 2 then
  begin
    a[x, y + 1] := 0;
    clear_occupied(x, y + 1);
  end;
  if a[x, y - 1] = 2 then
  begin
    a[x, y - 1] := 0;
    clear_occupied(x, y - 1);
  end;
end;

procedure draw_cells; // отрисовка игрового поля
var
  i, j: integer;
begin
  for i := 1 to n do //обходим в цикле все ячейки массива а (игрового поля)
    for j := 1 to m do
      case a[i][j] of //в зависимсти от содержимого ячейки рисуем
        0: //пустые клетки
          begin
            SetBrushColor(clWhite); //устанавливаем цвет кисти
            FillRect(i * 10, j * 10, i * 10 + 9, j * 10 + 9);//рисуем прямоугольник
           
          end;
        1: //заполненные клетки
          begin
            SetBrushColor(clBlack); //устанавливаем цвет кисти
            FillRect(i * 10, j * 10, i * 10 + 9, j * 10 + 9);//рисуем прямоугольник 
          end;
        2: //незаконченная линия
          begin
            SetBrushColor(clGreen); //устанавливаем цвет кисти
            FillRect(i * 10, j * 10, i * 10 + 9, j * 10 + 9);//рисуем прямоугольник
          end;
        3: //враги
          begin
            SetBrushColor(clRed); //устанавливаем цвет кисти
            FillRect(i * 10, j * 10, i * 10 + 9, j * 10 + 9);//рисуем прямоугольник
          end;
        4: //игрок
          begin
            SetBrushColor(clBlue); //устанавливаем цвет кисти
            FillRect(i * 10, j * 10, i * 10 + 9, j * 10 + 9);//рисуем прямоугольник
          end;
      end;
end;

procedure KeyDown2(key:integer);//игровой процесс
begin
case key of
VK_LEFT: //влево
      if player.x > 1 then //если игрок не в крайней левой позиции
      begin
        player.dx := -1; //устанавливаем игроку направление движения влево
        player.dy := 0; // и нулевую скорость по вертикали
      end;

    VK_RIGHT:
      if player.x < n then
      begin
        player.dx := 1;
        player.dy := 0;
      end;

    VK_UP:
      if player.y > 1 then
      begin
        player.dx := 0;
        player.dy := -1;
      end;
    VK_DOWN:
      if player.y < m then
      begin
        player.dx := 0;
        player.dy := 1;
      end;
  end;
end;

procedure NewGame; //новая игра
var
  i, j: Integer;
begin //создание новой игры
  for i := 1 to n do //очистка игрового поля
    for j := 1 to m do //
      if (i = 1) or (i = n) or (j = 1) or (j = m) then //
        a[i, j] := 1 // создание границ
      else //
        a[i, j] := 0; // создание пустого места
  a[1, 1] := 4; //создаем игрока
  player.x := 1; // и задаем ему координаты и скорость
  player.y := 1;
  player.dx := 0;
  player.dy := 0;
  for i := 1 to e do //в цикле от одного до количества врагов создаем врагов
  begin
    a[n div 2, i + 1] := 3;
      //добавляем врага по середине (по горизонтали) игрового поля
    enemys[i].x := n div 2; //записываем координаты врага в массив врагов
    enemys[i].y := i + 1;
    if Random(2) = 0 then //задаем случайную горизонтальную скорость
      enemys[i].dx := -1
    else
      enemys[i].dx := 1; //задаем случайную вертикальную скорость
    if Random(2) = 0 then
      enemys[i].dy := -1
    else
      enemys[i].dy := 1;
  end;
end;  

Procedure GameProc;
var
  i, j, k: Integer;
begin
  //передвижение врагов
  for i := 1 to  e do //перебираем в цикле массив врагов
    case a[enemys[i].x + enemys[i].dx, enemys[i].y + enemys[i].dy] of
      //если в ячейке куда переместится враг в результате хода
      0: //пусто
        begin //перемещаем врага
          a[enemys[i].x, enemys[i].y] := 0; //очищаем текущую ячейку
          a[enemys[i].x + enemys[i].dx, enemys[i].y + enemys[i].dy] := 3;
            //записываем в новую ячейку
          enemys[i].x := enemys[i].x + enemys[i].dx; //меняем координаты на новые
          enemys[i].y := enemys[i].y + enemys[i].dy;
        end;
      1: //заполненная ячейка
        begin
          if a[enemys[i].x + enemys[i].dx, enemys[i].y] = 1 then
            //если врезались в вертикальную стенку
            enemys[i].dx := 0 - enemys[i].dx; //меняем направление по горизонтали
          if a[enemys[i].x, enemys[i].y + enemys[i].dy] = 1 then
            //если врезались в горизонтальную стенку
            enemys[i].dy := 0 - enemys[i].dy; //меняем направление по вертикали
          if a[enemys[i].x + enemys[i].dx, enemys[i].y + enemys[i].dy] = 1 then
            //если врезались в угол
          begin //меняем оба направления(летим назад)
            enemys[i].dx := 0 - enemys[i].dx;
            enemys[i].dy := 0 - enemys[i].dy;
          end;
        end;
      3: //если врезались в врага
        begin
          enemys[i].dx := 0 - enemys[i].dx; //меняем направление по горизонтали
        end;
      4, 2: //если врезались в игрока или недостроенную стенку
        begin // конец игры
          fl:=True; //Конец игры
          st:='Вы проиграли';
        end;
    end;
  //передвижение игрока
  case a[player.x + player.dx, player.y + player.dy] of
    //если в ячейке куда переместится игрок в результате хода
    0: // пусто
      begin //перемещаем игрока
        a[player.x, player.y] := 2; //
        a[player.x + player.dx, player.y + player.dy] := 4;
        player.x := player.x + player.dx;
        player.y := player.y + player.dy;
      end;
    1: //заполненная ячейка
      begin //перемещаем игрока
        a[player.x, player.y] := 2;
        a[player.x + player.dx, player.y + player.dy] := 4;
        player.x := player.x + player.dx;
        player.y := player.y + player.dy;
       if player.x=1 then player.dx := 0;
        if player.y=1 then player.dy := 0;
        if player.x=60 then player.dx := 0;
        if player.y=40 then player.dy := 0;
        //в цикле меняем все ячейки в завершонной стене на заполненные
        for i := 1 to n do
          for j := 1 to m do
            if a[i, j] = 2 then
              a[i, j] := 1;
        //забиваем все пустые ячейки двойкой
        for i := 1 to n do
          for j := 1 to m do
            if a[i, j] = 0 then
              a[i, j] := 2;

        for i := 1 to e do //в цикле для каждого врага
          //вызываем процедуру очищающую участок вокруг врага от двоек
          clear_occupied(enemys[i].x, enemys[i].y);
        //в цикле заполняем все ячейки в которых остались двойки
        for i := 1 to n do
          for j := 1 to m do
            if a[i, j] = 2 then
              a[i, j] := 1;
        //подсчитываем количество заполненных ячеек
        k := 0; //сбрасываем счетчик заполненных ячеек
        for i := 1 to n do //в цикле обходим все ячейки
          for j := 1 to m do
            if a[i, j] = 1 then //и если ячейка заполнена
              k := k + 1; //увеличиваем счетчик заполненных ячеек
        pr:=round((k-2*m-2*n+4)*100/(m*n));
       //вывод информации по игре
       SetBrushColor(clWhite);
       FillRect(90, 410, 450,430);
       SetFontSize(20);
       SetFontColor(clBlue);
       TextOut(100,420,'Уровень: '+e);
       TextOut(300,420,'Захвачено: '+pr+'%');
  
        if k > m * n * p / 100 then //если заполнено больше p процентов ячеек
        begin //значит игра выиграна
          fl:=True; //Конец игры
          st:='Вы выиграли';
        end;
      end;
  end;
  draw_cells; //отрисовка игрового поля
end;
  
Begin
  assign(z,'C:\kk\kk.txt');
 onKeyDown := KeyDown;
 Zast;//вызов заставки
 1:e:=0;fl:=false;
 SetFontSize(10);
 
 
      clearwindow;
 textout(4,1,'Введите имя пользователя:');
 
 var j:string ;
 var pop:integer;
 pop:=30;
 textout(4,15,'Рекорды:');
 writeln('');
 reset(z);
 while not eof(z) do
   begin
   readln(z,j);
   writeln('');
  textout(4,pop,j);
  pop:=pop+17;
   end;
 
close(z);
   readln(q); 
   repeat
 Clearwindow;
 TextOut(1,1,'Выберите уровень (1-5): ');

 Readln(w);
val(w,e,err);
if err=0 then 
if (strtoint(w)>0) and (strtoint(w)<6) then
  e:=strtoint(w);

 until (e>0) and (e<6);
  
  
   
   

 2:fl:=false;
 if pr>60 then
 e:=e+1;
 onKeyDown := KeyDown2;
 SetBrushColor(clWhite);//очистка экрана
 FillRect(0, 0, 500,500);
 NewGame;
 SetFontSize(20);
 SetFontColor(clBlue);
 TextOut(100,420,'Уровень: '+e);
 TextOut(300,420,'Захвачено: 0%');
 repeat
  GameProc;
  Sleep(100);
 until fl=true;
  
clearwindow;
 SetFontSize(50);
 SetFontColor(clBlue);
 TextOut(100,150,st);//вывод результата игры
 
 Sleep(3000);//пауза
 SetFontSize(30);
 onKeyDown := KeyDown;
  if (e=5) and (st='Вы выиграли') then 
   begin
     append(z);
 writeln(z,q,' - ',e,' ','Уровень',', ','Захвачено',' ',pr,'%');
    close(z);
     Clearwindow;
   SetFontSize(50);
   SetFontColor(clBlue);
   SetBrushColor(clWhite);
   TextOut(130,150,'Конец игры');
   sleep(3000);
   Window.close;
   end;
 if st='Вы выиграли' then
 begin
   clearwindow;
   goto 2;
   end
   else
 begin
 repeat
 Clearwindow;
  SetBrushColor(clWhite);
  TextOut(1,1,'Начать новую игру? (y-да, n-нет)');Readln(ch);
 until (ch='y') or (ch='n');
 
 if ch='y' then
  begin
append(z);
 writeln(z,q,' - ',e,' ','Уровень',', ','Захвачено',' ',pr,'%');
    close(z);
   Clearwindow;
   
   goto 1;
  end
 else
 begin
  append(z);
 writeln(z,q,' - ',e,' ','Уровень',', ','Захвачено',' ',pr,'%');
    close(z);
   Clearwindow;
   SetFontSize(50);
   SetFontColor(clBlue);
   SetBrushColor(clWhite);
   TextOut(130,150,'Конец игры');
   sleep(3000);
   Window.close;
   
   
 
 end;
end;
end.