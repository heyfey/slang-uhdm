// r10v122 arm q5 - precedent stressors that MUST NOT move:
//   a `ref` formal local, a typedef'd local, a class-typed local, an enum
//   constant, a function-local parameter range, an implicit net.
package Nu5_pkg;
  typedef bit [13:0] Word14_t;
  typedef enum bit [2:0] { E_ZERO = 3'd0, E_ONE = 3'd1, E_TWO = 3'd2 } Code_e;

  class Holder1;
    Word14_t hv;
  endclass

  // ref formal - its references are the ref_var law's, not this one
  function automatic void refFormal(ref Word14_t rw, input int p1);
    if (p1 != 0) begin
      rw ^= 14'h1;
      rw[2] = 1'b1;
    end
  endfunction

  // a TYPEDEF'd local
  function automatic int tdLocal(int p2);
    Word14_t tdw;
    tdw = 14'h3;
    if (p2 != 1) begin
      tdw ^= 14'h4;
      tdw[5] = 1'b1;
    end
    tdLocal = int'(tdw);
  endfunction

  // a CLASS-TYPED local whose PROPERTY is selected (a hier_path lvalue)
  function automatic int clsLocal(int p3);
    Holder1 hh;
    hh = new();
    if (p3 != 2) begin
      hh.hv ^= 14'h6;
      hh.hv[7] = 1'b1;
    end
    clsLocal = int'(hh.hv);
  endfunction

  // an ENUM CONSTANT beside a selected local
  function automatic int enumBeside(int p4);
    Word14_t ew;
    Code_e   ec;
    ew = 14'h8;
    ec = E_ONE;
    if (p4 != 3) begin
      ew ^= 14'(ec);
      ew[9] = 1'b1;
    end
    enumBeside = int'(ew);
  endfunction

  // a function-LOCAL PARAMETER used as a RANGE bound
  function automatic int lpRange(int p5);
    localparam int WLP = 12;
    bit [WLP-1:0] lpv;
    lpv = 12'h1;
    if (p5 != 4) begin
      lpv ^= 12'h2;
      lpv[3] = 1'b1;
    end
    lpRange = int'(lpv);
  endfunction
endpackage

module Xi1_imp (input logic [3:0] din, output logic [3:0] dout);
  import Nu5_pkg::*;
  logic [3:0] r0;
  always_comb begin
    r0 = 4'(tdLocal(int'(din)) ^ clsLocal(int'(din)) ^ enumBeside(int'(din)));
  end
  assign dout = r0;
endmodule

module Xi2_expl (input logic [3:0] ein, output logic [3:0] eout);
  import Nu5_pkg::lpRange;
  logic [3:0] r1;
  always_comb begin
    r1 = 4'(lpRange(int'(ein)));
  end
  assign eout = r1;
endmodule
