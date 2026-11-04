// § defNetTypeParamPackedDim144
module top #(parameter type my_t = struct packed { logic [31:0] a; logic [15:0] b; }) (output logic [63:0] sum);
    my_t [2:0]  arr;
    assign arr = '0;
    assign sum = arr[0].a;
endmodule
