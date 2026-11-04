// § classTpUnitTdAliasClone418
typedef int BrickType;
class c;
  parameter type BT = BrickType;
endclass
module test;
  BrickType b;
  c h;
  initial h = new;
endmodule
