// § dottedCallHpSpansInvocation294
// CONTROL: an interface function called through an instance (a user call)
interface ifc; function int f(); return 3; endfunction endinterface
module top(output int o); ifc i(); assign o = i.f(); endmodule
