module n02;
  logic [7:0] data[];
  logic [7:0] bytes[];
  initial begin
    bytes = new[bytes.size + 1](bytes);
    bytes = new[data.size + 4];
    bytes = new[bytes.size];
  end
endmodule
