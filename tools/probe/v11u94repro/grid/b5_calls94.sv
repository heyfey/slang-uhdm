// v11u94 break arms: call and sys-call bounds, var keyword, typed pattern RHS
module b5 #(parameter int W = 8, parameter int unsigned D = 4) (input logic clk, input logic i, output logic o, output logic [7:0] q);
  function automatic int f(int x); return x * 2; endfunction
  typedef struct packed { logic [f(W)-1:0] x; } t01;
  localparam t01 c01_func = '{x: 1};
  typedef struct packed { logic [$bits(logic [W-1:0])-1:0] x; } t02;
  localparam t02 c02_bits = '{x: 1};
  typedef struct packed { logic [-W+20:0] x; } t03;
  localparam t03 c03_uminus = '{x: 1};
  typedef struct packed { logic [W-1:0] x; } t04;
  localparam t04 c04_typed = t04'{x: 1};
  localparam t04 c05_typedk = t04'{default: 1};
  typedef logic [7:0] a06_t [D];
  var a06_t v06_var;
  var logic [7:0] v07_plain [D];
  typedef logic [7:0] a08_t [D];
  a08_t v08_a;
  always_ff @(posedge clk) begin v06_var[0] <= 1; v08_a[0] <= 1; q <= v06_var[1] ^ v08_a[1]; end
  assign o = i ^ c01_func.x[0] ^ c04_typed.x[0];
endmodule
