import DWay;

void main(string[] args)
{
    // handle args
    
    auto app = new DWay.Field();
    scope(exit) destroy(app);
}
