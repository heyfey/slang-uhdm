interface di_leaf; int q; endinterface
interface di_holder_uninst;  di_leaf v(); endinterface   // never instantiated
interface di_holder_inst;    di_leaf w(); endinterface   // instantiated
module di_top; di_holder_inst u(); endmodule
