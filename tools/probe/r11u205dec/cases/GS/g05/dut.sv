// r11u205 GS g05: two nested for-generates, the inner genvar indexing a member
package rp;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } r_t;
endpackage
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input rp::r_t w, output logic [3:0] o);
  for (genvar j = 0; j < 2; j++) begin : ga
    for (genvar k = 0; k < 2; k++) begin : gb
      sub u(.i(w.a[j*2+k]), .o(o[j*2+k]));
    end
  end
endmodule
