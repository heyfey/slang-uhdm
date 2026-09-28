class C;
  logic [7:0] data[];
  function void f(ref logic [7:0] bytes[]);
    int x;
    bytes = new[bytes.size + 1](bytes);
    bytes = new[data.size + 4];
    bytes = new[bytes.size];
    bytes = new[bytes.size()];
    x = bytes.size + 1;
    bytes[bytes.size - 1] = 0;
  endfunction
endclass
module n01; endmodule
