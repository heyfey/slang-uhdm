// v92 adversarial arm 1: ElementSelect whose BASE is a member / hierarchical
// reference.  Our emitter mints a hier_path for these; Surelog's reduceExpr
// hier_path branch returns decodeHierPath(...,VALUE) == nullptr for a signal
// read, so writeCont's `&& rhstmp` refuses the WHOLE write-back and the
// ternary must SURVIVE.  kindOf92 maps ElementSelect -> OK92::Select
// unconditionally, without walking to the base.
package vp1;
  typedef struct packed { logic [3:0] m1; logic [3:0] m2; } st_t;
endpackage

module leaf1 (output logic [3:0] o);
  logic [3:0] arr;
  assign arr = 4'h5;
  assign o = arr;
endmodule

module v1_selbase #(parameter bit EN = 1) (
    input  vp1::st_t       st,
    input  logic [7:0]     k,
    output logic [3:0]     y_membersel,
    output logic [3:0]     y_hiersel,
    output logic [3:0]     y_memberbare,
    output logic [3:0]     y_ctl
);
  logic [3:0] warr [0:3];
  logic [3:0] o1;
  leaf1 u_leaf (.o(o1));

  // ElementSelect over a MEMBER base -> hier_path in both producers
  logic [7:0] pk;
  assign pk = {st.m2, st.m1};
  assign y_membersel  = EN ? st.m1        : 4'h0;   // bare member (control, must KEEP)
  assign y_memberbare = EN ? pk[3:0]      : 4'h0;   // part_select (must KEEP)
  // ElementSelect over a HIERARCHICAL base
  assign y_hiersel    = EN ? {3'b0, u_leaf.arr[0]} : 4'h0;  // operation arm -> folds
  assign y_ctl        = EN ? (k[5:4] ^ k[1:0]) : 4'h0;      // part_selects -> KEEP
endmodule
