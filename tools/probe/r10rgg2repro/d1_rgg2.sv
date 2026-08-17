// r10rgg2 d1 — RGGEN'S OWN FUNCTION, one instance per cell, one N per cell.
// This is `rggen_or_reducer.get_sub_n_list` verbatim (only the module name and
// the port list are dropped) so the write-back schedule is measured on the
// SHAPE THAT IS THE HEAD, not on a paraphrase.  Each cell has exactly one
// elaborated instance and one constant-evaluated call site, so the literal's
// value is the result of ONE evaluation at that N.
//
// The question each cell answers: when `list_index` has doubled past the
// array's last element, is the `list[list_index]` READ benign (0, so
// `current_n` never decreases and the loop spins until the literal wraps to
// the 0 fixpoint) or INVALID (so ExprEval's `if (invalidValue) break` ends the
// loop and the literal stops at a mid-range power of two)?
module h2_m #(parameter int N = 2) (output logic [15:0] o);
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
  localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);
  assign o = SUB_N_LIST[0];
endmodule

module h8_m #(parameter int N = 8) (output logic [15:0] o);
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
  localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);
  assign o = SUB_N_LIST[0];
endmodule

module h16_m #(parameter int N = 16) (output logic [15:0] o);
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
  localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);
  assign o = SUB_N_LIST[0];
endmodule

module h20_m #(parameter int N = 20) (output logic [15:0] o);
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
  localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);
  assign o = SUB_N_LIST[0];
endmodule

module h25_m #(parameter int N = 25) (output logic [15:0] o);
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
  localparam bit [N-1:0][15:0] SUB_N_LIST = get_sub_n_list(N);
  assign o = SUB_N_LIST[0];
endmodule

module d1_rgg2 (output logic [15:0] o);
  logic [15:0] v2, v8, v16, v20, v25;
  h2_m  #(.N(2))  u2  (.o(v2));
  h8_m  #(.N(8))  u8  (.o(v8));
  h16_m #(.N(16)) u16 (.o(v16));
  h20_m #(.N(20)) u20 (.o(v20));
  h25_m #(.N(25)) u25 (.o(v25));
  assign o = v2 ^ v8 ^ v16 ^ v20 ^ v25;
endmodule
