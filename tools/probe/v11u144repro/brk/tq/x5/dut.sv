// § defNetTypeParamPackedDim144
module top #(parameter type T = struct packed { logic a; logic [1:0] b; }) (output logic o);
    T [1:0] x, y, z;
    assign x = '0;
    assign y = '1;
    assign z = x;
    assign o = z[1].a ^ y[0].a;
endmodule
