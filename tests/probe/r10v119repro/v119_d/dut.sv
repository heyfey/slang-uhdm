// v119 arm D — WHAT THE CONSTRAINT BLOCK CONTAINS
package pk_d;
  parameter int unsigned PK_LIMIT = 40;
endpackage

class it_d;
  rand int unsigned d_a;
  rand int unsigned d_b;
  rand int unsigned d_arr[4];
  rand bit d_flag;
endclass

class drv_d;

  it_d r_d;
  int unsigned out_d;
  task run_d();
    // an EMPTY constraint block
    if (!r_d.randomize() with { }) out_d = 1;
    // solve ... before
    if (!r_d.randomize() with { solve d_a before d_b; d_a < 3; }) out_d = 2;
    // a dist expression
    if (!r_d.randomize() with { d_a dist { 1 := 4, 2 := 6 }; }) out_d = 3;
    // foreach over a rand array
    if (!r_d.randomize() with { foreach (d_arr[i]) d_arr[i] < 9; }) out_d = 4;
    // a soft constraint
    if (!r_d.randomize() with { soft d_b == 2; }) out_d = 5;
    // an implication
    if (!r_d.randomize() with { d_flag -> d_a > 5; }) out_d = 6;
    // if / else inside the block
    if (!r_d.randomize() with { if (d_flag) d_a < 4; else d_a > 6; }) out_d = 7;
    // inside, and a PACKAGE parameter reference
    if (!r_d.randomize() with { d_a inside { [1:pk_d::PK_LIMIT] }; }) out_d = 8;
    // several statements, one block
    if (!r_d.randomize() with { d_a > 1; d_b > 2; d_a != d_b; }) out_d = 9;
  endtask
endclass

module top_d2;
  drv_d dd_d;
  initial begin
    dd_d = new();
    dd_d.run_d();
  end
endmodule
