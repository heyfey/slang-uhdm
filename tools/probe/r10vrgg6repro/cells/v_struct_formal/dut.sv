
module m(input logic [3:0][1:0] i_data, output logic [1:0] o_result);
  typedef struct packed { bit [15:0] a; bit [15:0] b; } pair_t;
  function automatic pair_t s1(int n);
    pair_t r; r.a = 16'(n); r.b = 16'(n)+1; return r;
  endfunction
  function automatic pair_t s2(pair_t sa);
    pair_t r; r.a = sa.a+1; r.b = sa.b+1; return r;
  endfunction
  function automatic int s3(pair_t sb);
    return int'(sb.a) + int'(sb.b);
  endfunction
  localparam pair_t S1 = s1(4);
  localparam pair_t S2 = s2(S1);
  localparam int    S3 = s3(S2);
  logic [S3-1:0][1:0] nd;
  always_comb begin for (int i=0;i<S3;++i) nd[i]=i_data[0]; end
  always_comb o_result = nd[0];
endmodule
