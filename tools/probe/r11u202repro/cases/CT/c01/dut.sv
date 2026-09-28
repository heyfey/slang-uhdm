// § unitClassTdSpecAtName202
virtual class uvm_object;
endclass
class uvm_resource_db #(type T=int);
endclass
class uvm_config_db#(type T=int, type T2=int) extends uvm_resource_db#(T);
endclass
typedef uvm_config_db#(uvm_object, string) m_misc;
module top ();
  m_misc misc1 = new;
  uvm_config_db#(uvm_object, string) misc2 = new;
endmodule
