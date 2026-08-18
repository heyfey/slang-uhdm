module leaf (input logic p);
  wire w;
  assign w = p;
endmodule

module top #(
  parameter int P = 5
) (
  input logic [63:0] arr
);
  genvar i, j;
  for (i = 0; i < 2; ++i) begin : g
    leaf ua (.p (arr[i]));
    leaf ub (.p (arr[3+i]));
    leaf uc (.p (arr[2+4*i]));
    leaf ud (.p (arr[i*2+1]));
    leaf ue (.p (arr[P+i]));
    leaf uf (.p (arr[P]));
    leaf ug (.p (arr[7]));
    leaf uh (.p (arr[2+4*i+6]));
    for (j = 0; j < 2; ++j) begin : h
      leaf uj (.p (arr[1+2*i+j]));
      leaf uk (.p (arr[i+j]));
    end
  end
endmodule
