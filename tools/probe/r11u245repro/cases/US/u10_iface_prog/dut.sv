// § unitTdLawS245
// $unit typedefs in an interface, a program and a child module (variables and nets)
typedef bit [3:0] ub_t;
typedef string us_t;
interface ifc;
  ub_t iv;
  us_t is;
endinterface
program prg;
  ub_t pv;
  us_t ps;
endprogram
module child;
  ub_t cv;
  wire logic [3:0] cw;
endmodule
module top;
  ifc i();
  prg p();
  child c();
  ub_t tv;
endmodule
