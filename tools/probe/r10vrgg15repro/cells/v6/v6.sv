// v6 — HOMES: gen-scope, interface, package, class, typedef/enum/struct formals.
package pk;
  parameter bit [5:0] PP = '0;
  localparam bit [5:0] LP = '0;
endpackage
typedef bit [5:0] t6;
typedef enum bit [2:0] { EA = 0, EB = 1 } e3;
typedef struct packed { bit [3:0] a; bit [1:0] b; } st6;
module h6  #(parameter bit [5:0] P = '0) (); endmodule
module e_td #(parameter t6  P = '0) (); endmodule
module e_en #(parameter e3  P = EA) (); endmodule
module e_st #(parameter st6 P = '0) (); endmodule
interface ifc #(parameter bit [5:0] IP = '0) (); endinterface
class C #(parameter bit [5:0] CP = '0); endclass
module v6;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi = gi + 1) begin : gblk
      h6 #('0) g_h6 ();
      localparam bit [5:0] GL = '0;
    end
    if (1) begin : ifblk
      h6 #('0) i_h6 ();
    end
  endgenerate
  h6    #('0) u_h6 ();
  e_td  #('0) u_td ();
  e_st  #('0) u_st ();
  ifc   #('0) u_ifc ();
  localparam bit [5:0] BL = '0;
  C #('0) c_h;
endmodule
