module m #(
  parameter int WIDTH = 2,
  parameter int N = 4
)(
  input   logic [N-1:0][WIDTH-1:0]  i_data,
  output  logic [WIDTH-1:0]         o_result
);
  function automatic bit [N-1:0][15:0] f1(int n);
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

  function automatic bit [N-1:0][15:0] f2(bit [N-1:0][15:0] sub_n_list);
    bit [N-1:0][15:0] list;

    for (int i = 0;i < N;++i) begin
      if (i == 0) begin
        list[i] = 0;
      end
      else begin
        list[i] = sub_n_list[i-1] + list[i-1];
      end
    end

    return list;
  endfunction

  function automatic int f3(bit [N-1:0][15:0] sub_n_list);
    int next_n;

    next_n  = 0;
    for (int i = 0;i < N;++i) begin
      next_n  += ((sub_n_list[i] != 0) ? 1 : 0);
    end

    return next_n;
  endfunction

  localparam  bit [N-1:0][15:0] P1 = f1(N);
  localparam  bit [N-1:0][15:0] P2 = f2(P1);
  localparam  int               P3 = f3(P2);

  logic [P3-1:0][WIDTH-1:0] next_data;

  always_comb begin
    for (int i = 0;i < P3;++i) begin
      next_data[i]  = i_data[0];
    end
  end

  always_comb begin
    o_result = next_data[0];
  end
endmodule

module top(
  input logic [63:0][1:0] d,
  output logic [1:0] q0, output logic [1:0] q1, output logic [1:0] q2
);
  m #(.WIDTH(2), .N(4)) u0 (.i_data(d[4-1:0]), .o_result(q0));
  m #(.WIDTH(2), .N(4)) u1 (.i_data(d[4-1:0]), .o_result(q1));
  assign q2 = q0;
endmodule
