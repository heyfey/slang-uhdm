// r10uvm56 arm a6 — DOES THE RULE KEY ON THE RETURN TYPE?  A CLASS HANDLE (the
// witness shape) against an INTEGRAL one and a STRUCT and a STRING, at class
// IN-BODY scope and at module scope.
typedef struct packed {
   int a;
   int b;
} s6_t;

class h6;
   int v;
endclass

class c6;
   function h6 y_class(h6 y);
      y_class = y;
      if (y_class == null)
        y_class = y;
   endfunction
   function int y_int(int y);
      y_int = y;
      if (y_int == 0)
        y_int = 1;
   endfunction
   function s6_t y_struct(s6_t y);
      y_struct = y;
      if (y_struct.a == 0)
        y_struct.a = 1;
   endfunction
   function string y_string(string y);
      y_string = y;
      if (y_string == "")
        y_string = "x";
   endfunction
endclass

module a6_top;
   function h6 z_class(h6 y);
      z_class = y;
      if (z_class == null)
        z_class = y;
   endfunction
   function int z_int(int y);
      z_int = y;
      if (z_int == 0)
        z_int = 1;
   endfunction
   function s6_t z_struct(s6_t y);
      z_struct = y;
      if (z_struct.a == 0)
        z_struct.a = 1;
   endfunction
   function string z_string(string y);
      z_string = y;
      if (z_string == "")
        z_string = "x";
   endfunction

   int r;
   c6 h;
   initial begin
      h = new();
      r = z_int(1) + h.y_int(1);
   end
endmodule
