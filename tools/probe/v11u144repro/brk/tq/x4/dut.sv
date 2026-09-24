// § defNetTypeParamPackedDim144
module top #(parameter type T = struct packed { logic a; logic [1:0] b; }) (output logic o);
    T [1:0] x [2];
    T [2:0] y;
    assign x[0] = '0;
    assign x[1] = '1;
    assign y = '0;
    assign o = x[1][0].a ^ y[0].a;
endmodule
