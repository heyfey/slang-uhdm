// § cloneMembEnumAtHomeListing265 (fresh: the method and the writer in a header included into two home packages)
typedef enum {OK, NOK} st_e;
typedef struct { int a; st_e status; } op_t;
class c;
  extern task f(output st_e s1);
endclass
task c::f(output st_e s1);
  begin
    op_t rw;
    s1 = rw.status;
  end
endtask
task g(output st_e s2);
  s2 = OK;
endtask
