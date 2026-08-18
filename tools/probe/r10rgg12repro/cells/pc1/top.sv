interface ifc;
  logic [3:0] x;
endinterface

module inner #(parameter int N = 4)();
  function automatic bit [3:0][15:0] f_while(int n);
    bit [3:0][15:0] list;
    int idx;
    bit [15:0] cur;
    list = '0;
    idx  = 0;
    cur  = 16'(n);
    while (cur > 0) begin
      if (cur >= 4) list[idx] = 4;
      else          list[idx] = cur;
      cur -= list[idx];
      idx += 1;
    end
    return list;
  endfunction
  function automatic int f_terneq(bit [3:0][15:0] a);
    int acc;
    acc = 0;
    for (int i = 0;i < 4;++i) acc += ((a[i] != 0) ? 1 : 0);
    return acc;
  endfunction
  localparam bit [3:0][15:0] SUBL = f_while(N);
  localparam int P = f_terneq(SUBL);
  logic [P-1:0] v;
  always_comb begin
    v = '0;
  end
endmodule

module mid #(parameter int N = 4)();
  ifc u_if();
  inner #(.N(N)) u_in ();
endmodule

module top;
  mid #(.N(4)) u_m1 ();
  mid #(.N(6)) u_m2 ();
  mid #(.N(8)) u_m3 ();
endmodule
