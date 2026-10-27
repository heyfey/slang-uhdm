// § progLocalDeclNets444
program prg;
int x;
initial begin
  fork
    begin
      int fl;
      fl = x;
    end
  join
end
final begin
  int z;
  z = x;
end
endprogram
