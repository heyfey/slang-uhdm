// § uninstIfaceIncDecBinds441
interface ifc;
  typedef struct { int f; int g; } st_t;
  task t(int s);
    st_t v;
    v.f++;
    s++;
  endtask
endinterface
