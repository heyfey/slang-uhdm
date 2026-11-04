// § forInitSelectLhsBase254 (an output port struct, a ref formal and a named-block local as the initializer base)
typedef struct packed { logic [3:0] a; } s_t;
module top(output s_t so, output int o);
  task automatic t(ref s_t r, output int n);
    n = 0;
    for (r.a = 0; r.a < 2; r.a++) n++;
  endtask
  initial begin : ib
    s_t loc;
    o = 0;
    for (so.a = 0; so.a < 2; so.a++) o++;
    for (loc.a = 0; loc.a < 2; loc.a++) o++;
    t(loc, o);
  end
endmodule
