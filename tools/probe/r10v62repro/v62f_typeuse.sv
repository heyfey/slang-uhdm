// v62f — WHERE the module-local TYPEDEF is used as a type: port, function
// return, task arg, parameter type, nested typedef, chained alias, forward
// typedef, typedef inside a nested generate module, class property.
module chld62 (input logic [3:0] i, output logic [3:0] q);
  assign q = i;
endmodule

module tu62 #(parameter int W = 4) (
  input  logic clk,
  output logic [W-1:0] dout,
  output logic [7:0]   st
);
  typedef enum logic [1:0] { TA, TB, TC } t_e;
  typedef struct packed { t_e op; logic [1:0] sz; } t_t;
  typedef t_t            t_alias;      // chained alias of a module-local td
  typedef struct packed { t_t inner; logic tag; } t_out;
  typedef t_t t_arr_t [0:1];           // typedef of an unpacked array

  t_t     a;
  t_alias b;
  t_out   c;
  t_arr_t d;
  t_t     e [0:1];

  function automatic t_t mk(input t_e o);
    mk = '{op:o, sz:2'b01};
  endfunction
  task automatic usev(input t_t v, output logic r);
    begin
      r = (v.op == TB);
    end
  endtask
  logic r0, r1;
  always_comb begin a = mk(TA); usev(a, r0); end
  assign b = '{op:TB, sz:2'b10};
  assign c = '{inner:b, tag:1'b1};
  assign r1 = (c.inner.op == TB) & (d[0].sz == 2'b00) & (e[1].sz == 2'b00);
  logic [3:0] cq;
  chld62 u_ch (.i({a.op, a.sz}), .q(cq));
  assign st = {2'b0, cq, r1, r0};
  assign dout = { {(W-2){1'b0}}, a.sz };
endmodule

module top62f (input logic clk, output logic [15:0] o);
  logic [3:0] d4; logic [15:0] d16; logic [7:0] s1, s2;
  tu62 #(.W(4))  u_a (.clk(clk), .dout(d4),  .st(s1));
  tu62 #(.W(16)) u_b (.clk(clk), .dout(d16), .st(s2));
  assign o = d16 ^ {12'b0, d4} ^ {s1, s2};
endmodule
