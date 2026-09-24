// § defNetTypeParamPackedDim144
module top #(parameter type U = union packed { logic [3:0] a; logic [3:0] b; }) (output logic o);
    U [1:0] x;
    assign x = '0;
    assign o = x[1].a[0];
endmodule
