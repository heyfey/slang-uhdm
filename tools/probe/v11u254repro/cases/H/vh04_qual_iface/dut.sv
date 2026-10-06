// § hcSelIdxTsSkipsPort254 (a package-qualified index without an import, an interface instance's port, a module-local package import)
package pk;
  parameter int unsigned PMP_I = 0;
  parameter int unsigned PMP_D = 1;
endpackage
interface ifc (input logic a);
endinterface
module sub (input logic a);
endmodule
module top;
  logic [2:0] e;
  sub u (.a(e[pk::PMP_D]));
  ifc i (.a(e[pk::PMP_I]));
endmodule
