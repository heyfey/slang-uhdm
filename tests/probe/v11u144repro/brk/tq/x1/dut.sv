// § defNetTypeParamPackedDim144
module top #(parameter type T = struct packed { logic a; logic [2:0] b; }) (output logic o);
    T [1:0][2:0] x;
    T [3:0] y;
    assign x = '0;
    assign y = '0;
    assign o = x[0][1].a ^ y[2].a;
endmodule
