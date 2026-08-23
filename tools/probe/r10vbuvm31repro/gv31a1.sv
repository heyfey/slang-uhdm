// v31a1 — CLAUSE-3 ADVERSARY: explicit constant widths and odd element widths
// at all three carriers (package / module / class property).
package v31p1;
  int           pw_a[]   = '{1, 64'd9, 32'd7};
  byte          pw_b[]   = '{8'hff, 300};
  logic [127:0] pw_c[]   = '{1, 2};
  longint       pw_f[]   = '{1, 2};
  string        pw_g[]   = '{"a", "bb"};
  int           pw_h[]   = {1, 64'd9};
  int           pw_i[string] = '{"x": 64'd9, default: 5};
  bit [2:0]     pw_j[]   = '{1, 2, 3};
  int           pw_k[$]  = '{9, 64'd4};
endpackage

module v31m1;
  int           mw_a[]   = '{1, 64'd9, 32'd7};
  byte          mw_b[]   = '{8'hff, 300};
  logic [127:0] mw_c[]   = '{1, 2};
  longint       mw_f[]   = '{1, 2};
  string        mw_g[]   = '{"a", "bb"};
  int           mw_h[]   = {1, 64'd9};
  int           mw_i[string] = '{"x": 64'd9, default: 5};
  bit [2:0]     mw_j[]   = '{1, 2, 3};
  int           mw_k[$]  = '{9, 64'd4};

  class v31c1;
    int           cw_a[]   = '{1, 64'd9, 32'd7};
    byte          cw_b[]   = '{8'hff, 300};
    logic [127:0] cw_c[]   = '{1, 2};
    longint       cw_f[]   = '{1, 2};
    string        cw_g[]   = '{"a", "bb"};
    int           cw_h[]   = {1, 64'd9};
    int           cw_i[string] = '{"x": 64'd9, default: 5};
    bit [2:0]     cw_j[]   = '{1, 2, 3};
    int           cw_k[$]  = '{9, 64'd4};
    int           cw_fix[3] = '{1, 64'd9, 3};
  endclass

  v31c1 h1 = new();
  initial $display("%p", h1.cw_a);
endmodule
