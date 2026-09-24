// § defNetTypeParamPackedDim144
module top #(parameter type T = logic [7:0]) (output logic [63:0] sum);
    T [2:0]  arr;
    assign arr = '0;
    assign sum = arr[0];
endmodule
