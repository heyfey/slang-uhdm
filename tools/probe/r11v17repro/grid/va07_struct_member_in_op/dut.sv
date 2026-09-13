// A STRUCT MEMBER SELECT inside the operation Rhs.
module top(input logic [31:0] a, output logic [31:0] o);
  typedef struct packed { logic [15:0] hi; logic [15:0] lo; } st_t;
  st_t s;
  logic [31:0] mv;
  assign s = a;
  if (1) begin : gb
    logic [15:0] src;
    assign src = a[15:0];
    assign mv = {s.hi, src};
  end
  assign o = mv;
endmodule
