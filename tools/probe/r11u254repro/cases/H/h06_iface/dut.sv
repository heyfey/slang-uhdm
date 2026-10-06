// § hcSelIdxTsSkipsPort254 (an interface instance connected through a select, beside a module instance)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
module sub (input logic i);
endmodule
interface ifc (input logic a);
endinterface
module top;
  import pk::*;
  logic [2:0] e;
  ifc ii (.a(e[PMP_I]));
  sub u (.i(e[PMP_D]));
endmodule
