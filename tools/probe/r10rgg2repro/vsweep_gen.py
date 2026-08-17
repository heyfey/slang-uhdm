import os
HDR = '''module orv #(
  parameter int WIDTH = 2,
  parameter int N     = 20
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
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
  function automatic bit [N-1:0][15:0] get_offset_list(bit [N-1:0][15:0] sub_n_list);
    bit [N-1:0][15:0] list;
    for (int i = 0;i < N;++i) begin
      if (i == 0) list[i] = 0;
      else        list[i] = sub_n_list[i-1] + list[i-1];
    end
    return list;
  endfunction
  function automatic int get_next_n(bit [N-1:0][15:0] sub_n_list);
    int next_n;
    next_n  = 0;
    for (int i = 0;i < N;++i) next_n += ((sub_n_list[i] != 0) ? 1 : 0);
    return next_n;
  endfunction
  localparam  bit [N-1:0][15:0] SUB_N_LIST  = get_sub_n_list(N);
'''
PARTS = {
 'v1': '',
 'v2': '  localparam  bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n',
 'v3': '  localparam  bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n'
       '  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);\n',
 'v4': '  localparam  bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n'
       '  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);\n'
       '  logic [NEXT_N-1:0][WIDTH-1:0] next_data;\n',
 'v5': '  localparam  bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n'
       '  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);\n'
       '  logic [NEXT_N-1:0][WIDTH-1:0] next_data;\n'
       '  always_comb begin\n'
       '    for (int i = 0;i < NEXT_N;++i) begin\n'
       '      if (SUB_N_LIST[i] == 4) next_data[i] = i_data[OFFSET_LIST[i]+0];\n'
       '      else                    next_data[i] = i_data[OFFSET_LIST[i]+1];\n'
       '    end\n'
       '  end\n',
 'v6': '  localparam  bit [N-1:0][15:0] OFFSET_LIST = get_offset_list(SUB_N_LIST);\n'
       '  localparam  int               NEXT_N      = get_next_n(SUB_N_LIST);\n'
       '  logic [NEXT_N-1:0][WIDTH-1:0] next_data;\n'
       '  always_comb begin\n'
       '    for (int i = 0;i < NEXT_N;++i) begin\n'
       '      if (SUB_N_LIST[i] == 4) next_data[i] = i_data[OFFSET_LIST[i]+0];\n'
       '      else                    next_data[i] = i_data[OFFSET_LIST[i]+1];\n'
       '    end\n'
       '  end\n'
       '  generate\n'
       '    if (NEXT_N > 1) begin : g_reduce\n'
       '      orv #(.WIDTH(WIDTH), .N(NEXT_N)) u_reducer (.i_data(next_data), .o_result(o_result));\n'
       '    end\n'
       '    else begin : g_reduce\n'
       '      always_comb o_result = next_data[0];\n'
       '    end\n'
       '  endgenerate\n',
}
TAIL = 'endmodule\n'
for k, extra in PARTS.items():
    for nval in (20, 25):
        d = '%s_n%d' % (k, nval)
        os.makedirs(d, exist_ok=True)
        with open(d + '/orv.sv', 'wt') as f:
            f.write(HDR + extra + ('  assign o_result = SUB_N_LIST[0][WIDTH-1:0];\n'
                                   if k in ('v1', 'v2', 'v3', 'v4', 'v5') else '') + TAIL)
        with open(d + '/top.sv', 'wt') as f:
            f.write('module top;\n  orv #(.WIDTH(2), .N(%d)) u0 (.i_data(), .o_result());\nendmodule\n' % nval)
