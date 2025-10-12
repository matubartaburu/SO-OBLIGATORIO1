#include <pthread.h>
#include <stdio.h> 
#include <stdlib.h>
#include <unistd.h>
pthread_mutex_t cartel; //recursocompartido.
pthread_mutex_t lectores; 
int cantlectores = 0; 

void* funcion_oficinista(void*arg); 
void* funcion_pasajero(void*arg); 

int main() {
pthread_mutex_init(&cartel, NULL); 
pthread_mutex_init(&lectores, NULL); 
pthread_t hilos_pasajeros[100]; //necesario sobre todo por el join.
pthread_t hilos_oficinistas[5];  
int Pasajeros[100]; //uso posiciones al imprimir.
int Oficinistas[5]; 
for(int i = 0; i<100; i++) {
    Pasajeros[i] = i +1; 
    pthread_create(&hilos_pasajeros[i], NULL, funcion_pasajero, &Pasajeros[i]); 
}
for(int i = 0; i<5; i++) {
    Oficinistas[i] = i+1; 
    pthread_create(&hilos_oficinistas[i], NULL, funcion_oficinista, &Oficinistas[i]); 
}

for(int i = 0; i<100; i++) { 
pthread_join(hilos_pasajeros[i], NULL); 

} 

for(int i = 0; i<5; i++) {  
pthread_join(hilos_oficinistas[i], NULL);

}

pthread_mutex_destroy(&lectores); 
pthread_mutex_destroy(&cartel); 

return 0; 
}


void* funcion_pasajero(void*arg){ 
int id = *(int *)arg;
pthread_mutex_lock(&lectores); 
cantlectores++; 
if(cantlectores == 1) {
    pthread_mutex_lock(&cartel); 
}
pthread_mutex_unlock(&lectores); 

printf("Pasajero %d esta mirando el cartel\n", id);
sleep(rand() % 3 + 1); //tiempo random que lee el cartel. 
pthread_mutex_lock(&lectores); 
cantlectores--; 
if(cantlectores == 0) {
    pthread_mutex_unlock(&cartel); 
}
pthread_mutex_unlock(&lectores); //dar libertad una vez termiando. 
return NULL; 
}; 

void* funcion_oficinista(void*arg){ 
    int id = *(int* ) arg; 

    for(int i = 0; i<3 ;i++) {
        pthread_mutex_lock(&cartel); 

    printf("Oficinista %d esta modificando el cartel\n" , id);
    sleep(rand() % 5 + 1);
    pthread_mutex_unlock(&cartel); //duda si va dentro
    }
 

}; 