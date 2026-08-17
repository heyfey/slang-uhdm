// v54 VERIFIER ARM v8 — THE earl51 CONT-ASSIGN LHS BOUNDARY, replicated.
// earl51's law split on WHOLE-SIGNAL vs MEMBER LHS in a cont-assign.  This law
// claims golden KEEPS op34 in every cont-assign RHS regardless of LHS shape,
// and in procedural assignments; a1 measured exactly two of those cells.  Here
// the same written replication is put behind every LHS shape earl51 named, plus
// a net-decl-assign and a generate-scope cont-assign (the ~1524-cell shape the
// integration note re-measured in the constant>ref_obj family).
package pkv8_54;
  parameter int N = 4;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } sv8_t;
endpackage
module snkv8_54 (input [7:0] a, output [7:0] o);
  assign o = ~a;
endmodule
module v8_v54 (input logic sel, input logic [7:0] d, output logic [7:0] q);
  pkv8_54::sv8_t      st;
  logic [7:0]         wa, wb;
  logic [1:0][3:0]    arr;
  // whole-signal LHS
  assign wa = {sel ? d[3:0] : {4{1'b0}}, 4'h1};
  // MEMBER LHS
  assign st.hi = (sel ? d[3:0] : {4{1'b0}});
  // ELEMENT LHS
  assign arr[0] = (sel ? d[3:0] : {4{1'b1}});
  // PART-SELECT LHS
  assign wb[7:4] = (sel ? d[3:0] : {4{1'b1}});
  // NET-DECL-ASSIGN
  wire [7:0] wn = {sel ? d[3:0] : {4{1'b0}}, 4'h2};
  // CONCAT LHS
  logic [3:0] c1, c2;
  assign {c1, c2} = {sel ? d[3:0] : {4{1'b1}}, 4'h3};
  // GENERATE-SCOPE cont-assign
  for (genvar gi = 0; gi < 2; gi++) begin : gen_v8
    logic [7:0] gw;
    assign gw = {sel ? d[3:0] : {4{1'b0}}, 4'h4};
  end
  // PROCEDURAL forms
  logic [7:0] pa, pb;
  always_comb pa = {sel ? d[3:0] : {4{1'b1}}, 4'h5};
  always_comb begin
    if (sel) pb = {sel ? d[3:0] : {4{1'b0}}, 4'h6};
    else     pb = 8'h0;
  end
  // and the SAME replication where the law DOES fire, in the same file
  snkv8_54 u_conn (.a({sel ? d[3:0] : {4{1'b0}}, 4'h7}), .o());
  assign q = wa ^ wb ^ wn ^ {c1, c2} ^ pa ^ pb ^ {st.hi, st.lo} ^ {arr[1], arr[0]};
endmodule
