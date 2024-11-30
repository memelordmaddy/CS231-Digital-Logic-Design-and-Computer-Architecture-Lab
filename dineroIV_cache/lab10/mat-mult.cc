#define size 500 // add iostream and change to 100 for 2nd part
using namespace std;
int main()
{
    double A[size][size];
    double B[size][size];
    double C[size][size];
    for(int i=0; i<size; i++) 
    {
        for(int j=0; j<size; j++)
        {
            A[i][j]=0;
            B[i][j]=0;
            C[i][j]=0;
        }
    }
    for(int i=0; i<size; i++)
    {
        B[i][i]=2;
        C[0][i]=i;
    }

    for(int i=0; i<size; i++)
    {
        for(int j=0; j<size; j++)
        {
            for(int k=0; k<size; k++)
            {
                /*
                cout<<0<<" "<<&A[i][j]<<"\n";
                cout<<0<<" "<<&B[i][k]<<"\n";
                cout<<0<<" "<<&C[k][j]<<"\n";
                cout<<1<<" "<<&A[i][j]<<"\n";
                */
                A[i][j] += B[i][k]*C[k][j];
            }
        }
    }    
}