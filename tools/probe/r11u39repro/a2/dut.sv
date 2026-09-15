// r11u39 arm a2 — HOLDERS and VIEWS for the member multi-select element,
// plus the MID-PATH (member below a multi-selected member) cell, which the
// emitter already reaches today and which the law must not break.
package p2;
  typedef struct packed { logic a; logic b; } leaf_t;
  typedef struct packed {
    leaf_t [3:0][1:0] lv;        // TWO packed dims, a STRUCT element -> a
                                 // member can follow the multi-select
    logic  [3:0][1:0] sat;
  } e_t;
endpackage

interface ifc;
  p2::e_t [1:0][1:0] tb;
  modport mp (input tb);
endinterface

module sub (input logic x, output logic y);
  assign y = x;
endmodule

module dut (
    input  logic        r_i, c_i,
    input  logic [1:0]  s_i,
    input  logic [255:0] flat_i,
    output logic        ca_rv, ca_lvq,
    output logic        pr_rv, pr_lv,
    output logic        fn_o, gen_o, if_o, cond_o, arg_o, hi_o
);
  p2::e_t [1:0][1:0] tb;
  logic [1:0] lvq;
  assign tb = flat_i[95:0];

  // MID-PATH: a member BELOW a two-index member select (reached today).
  assign ca_rv = tb[r_i][c_i].lv[s_i][1].a;

  // cont_assign LVALUE on the same shape
  assign ca_lvq = lvq[0];
  always_comb begin
    logic [1:0] tmp;
    // process RVALUE and LVALUE
    pr_rv = tb[r_i][c_i].sat[s_i][1];
    tmp    = 2'b00;
    lvq[0] = tb[r_i][c_i].lv[s_i][1].b;
    pr_lv  = tmp[0];
  end

  function automatic logic f2(input logic [1:0] q);
    return tb[r_i][c_i].sat[q][1];
  endfunction
  assign fn_o = f2(s_i);

  // condition position and call-argument position
  assign cond_o = tb[r_i][c_i].sat[s_i][1] ? 1'b1 : 1'b0;
  assign arg_o  = f2({1'b0, tb[r_i][c_i].sat[s_i][1]});

  // generate scope (def view vs elab view)
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gb
      logic w;
      assign w = tb[gi][c_i].sat[s_i][1];
    end
  endgenerate
  assign gen_o = gb[0].w;

  // interface instance holder
  ifc u_if();
  assign if_o = u_if.tb[r_i][c_i].sat[s_i][1];

  // module instance HIGH-CONN holder
  sub u_sub(.x(tb[r_i][c_i].sat[s_i][1]), .y(hi_o));
endmodule
