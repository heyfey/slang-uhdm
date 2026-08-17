// X1 -- argument SHAPES the law must not touch, in a body that IS in the
// saturated regime (Rggen's get_sub_n_list verbatim, two instances, the demand
// gate satisfied by NEXT_N).  Every other call's argument must come out
// byte-identical on base and patched:
//   NLIT   = h(4)            literal argument
//   NSCAL  = h(K)            SCALAR localparam argument
//   NNEST  = get_next_n(id(SUB_N_LIST))   the escaping param at call depth 2
//   NCOPY  = get_next_n(COPY)             a packed-array COPY of the escaping param
module x1_sub #(parameter int WIDTH = 2, parameter int N = 1) ();
  function automatic bit [N-1:0][15:0] get_sub_n_list(int n);
    bit [N-1:0][15:0] list;
    int               list_index;
    bit [15:0]        current_n;
    bit [15:0]        half_n;
    list        = '0;
    list_index  = 0;
    current_n   = 16'(n);
    while (current_n > 0) begin
      half_n  = current_n / 2;
      if ((current_n > 4) && (half_n <= 4)) begin
        list[list_index]  = half_n;
      end
      else if (current_n >= 4) begin
        list[list_index]  = 4;
      end
      else begin
        list[list_index]  = current_n;
      end
      current_n   -= list[list_index];
      list_index  += 1;
    end
    return list;
  endfunction
  function automatic int get_next_n(bit [N-1:0][15:0] sub_n_list);
    int next_n;
    next_n  = 0;
    for (int i = 0;i < N;++i) begin
      next_n  += ((sub_n_list[i] != 0) ? 1 : 0);
    end
    return next_n;
  endfunction
  function automatic int h(int q);
    return q + 1;
  endfunction
  function automatic bit [N-1:0][15:0] id(bit [N-1:0][15:0] z);
    return z;
  endfunction
  localparam  int               K           = 7;
  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
  localparam  bit [N-1:0][15:0] COPY        = SUB_N_LIST;
  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);
  localparam  int               NLIT        = h(4);
  localparam  int               NSCAL       = h(K);
  localparam  int               NNEST       = get_next_n(id(SUB_N_LIST));
  localparam  int               NCOPY       = get_next_n(COPY);
  logic [NEXT_N-1:0][WIDTH-1:0] next_data;
  logic [NLIT+NSCAL+NNEST+NCOPY-1:0] sink;
endmodule
module top_x1_argshapes;
  x1_sub #(.WIDTH(2), .N(25)) u00 ();
  x1_sub #(.WIDTH(2), .N(25)) u01 ();
endmodule
