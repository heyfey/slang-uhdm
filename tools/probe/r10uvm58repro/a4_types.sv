// r10uvm58 arm a4 — EVERY TYPE A TYPE PARAMETER CAN DEFAULT TO, one class per
// default, each with the SAME `virtual function T get();` shape.  Axis 4.
package p58a4;
   typedef enum int { E0, E1 } e58_t;
   typedef struct packed { bit [3:0] a; bit [3:0] b; } s58_t;
   class k58;
      int x;
   endclass

   virtual class d_int    #(type T=int)     ; pure virtual function T get(); endclass
   virtual class d_bit    #(type T=bit)     ; pure virtual function T get(); endclass
   virtual class d_byte   #(type T=byte)    ; pure virtual function T get(); endclass
   virtual class d_string #(type T=string)  ; pure virtual function T get(); endclass
   virtual class d_enum   #(type T=e58_t)   ; pure virtual function T get(); endclass
   virtual class d_struct #(type T=s58_t)   ; pure virtual function T get(); endclass
   virtual class d_class  #(type T=k58)     ; pure virtual function T get(); endclass
   virtual class d_nodef  #(type T)         ; pure virtual function T get(); endclass
   virtual class d_chain  #(type T=int, type U=T) ; pure virtual function U get(); endclass
   virtual class d_logic  #(type T=logic)   ; pure virtual function T get(); endclass
   virtual class d_real   #(type T=real)    ; pure virtual function T get(); endclass
endpackage

module a4_top58;
   initial begin end
endmodule
