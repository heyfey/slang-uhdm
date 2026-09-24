// v119 arm H — WHAT THE WITH-BLOCK REFERENCES
package pk_h;
  parameter int unsigned PK_CAP = 33;
endpackage

class it_h2;
  rand int unsigned h_v;
  rand int unsigned h_w;
  int unsigned h_const;
endclass

class drv_h2;

  it_h2 r_h2;
  int unsigned prop_h;          // a CALLER class property
  parameter int unsigned CL_CAP = 21;
  int unsigned out_h2;
  task run_h2(input int unsigned arg_h);
    int unsigned loc_h;
    loc_h = 4;
    // the RECEIVER's own members only
    if (!r_h2.randomize() with { h_v < h_w; }) out_h2 = 1;
    // a TASK LOCAL
    if (!r_h2.randomize() with { h_v > loc_h; }) out_h2 = 2;
    // a TASK ARGUMENT
    if (!r_h2.randomize() with { h_v > arg_h; }) out_h2 = 3;
    // the CALLER's class property
    if (!r_h2.randomize() with { h_v > prop_h; }) out_h2 = 4;
    // a PACKAGE parameter
    if (!r_h2.randomize() with { h_v < pk_h::PK_CAP; }) out_h2 = 5;
    // a CLASS parameter
    if (!r_h2.randomize() with { h_w < CL_CAP; }) out_h2 = 6;
    // the receiver's NON-rand member
    if (!r_h2.randomize() with { h_v > r_h2.h_const; }) out_h2 = 7;
    // a literal only
    if (!r_h2.randomize() with { h_v == 12; }) out_h2 = 8;
  endtask
endclass

module top_h2;
  drv_h2 d_h2;
  it_h2 mm_h;
  int unsigned mod_h_out;
  parameter int unsigned MOD_CAP = 55;
  initial begin
    d_h2 = new();
    mm_h = new();
    d_h2.run_h2(6);
    // a MODULE parameter, module home
    if (!mm_h.randomize() with { h_v < MOD_CAP; }) mod_h_out = 1;
  end
endmodule
