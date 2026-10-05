// § contLvMidSelNetBase246
package hp;
  typedef struct packed { logic [7:0] d; } key_t;
  typedef struct packed { key_t [3:0] key; logic v; } s_t;
endpackage
interface bus;
  logic [7:0] q;
  function int cnt();
    static int n;
    return n;
  endfunction
  function int peek(); return cnt.n; endfunction
endinterface
module sub import hp::*; #(parameter int N = 2) (bus b, output logic [7:0] o);
  wire s_t w;
  function automatic bit [N-1:0][7:0] f(int n);
    bit [N-1:0][7:0] r;
    for (int i = 0; i < n; i++) r[i] = 8'(i);
    return r;
  endfunction
  localparam bit [N-1:0][7:0] L = f(N);
  assign w.key[N-1].d = L[0];
  assign w.key[N].d = {N{1'b1}};
  assign w.key[0].d[N +: 2] = 2'b10;
  assign impl_y = w.v;
  assign o = w.key[1].d ^ b.q;
endmodule
module top(output logic [7:0] o);
  bus b0();
  sub #(.N(3)) u(.b(b0), .o(o));
endmodule
