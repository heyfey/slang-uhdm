// § hpVarSelRangeIdxNamesByPath220
class C;
  logic [3:0][7:0] arr;
endclass
module top(input int i, output logic [3:0] o);
  C h;
  initial begin
    h = new;
    o = h.arr[i][3:0];
  end
endmodule
