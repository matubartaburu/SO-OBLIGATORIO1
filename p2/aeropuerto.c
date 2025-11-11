#include <pthread.h>
#include <stdio.h> 
#include <stdlib.h>
#include <semaphore.h>
#include <unistd.h>
sem_t cartel; //recursocompartido.

void* funcion_oficinista(void*arg); 
void* funcion_pasajero(void*arg); 

int main() {
sem_init(&cartel, 0, 1); //inicializo recurso ya creado. 
pthread_t hilos_pasajeros[100]; 
pthread_t hilos_oficinistas[5];  
int Pasajeros[100]; //uso posiciones al imprimir.
int Oficinistas[5]; 
for(int i = 0; i<5; i++) {
    Oficinistas[i] = i+1; 
    pthread_create(&hilos_oficinistas[i], NULL, funcion_oficinista, &Oficinistas[i]); 
}
for (int i = 0; i < 50; i++) {
        Pasajeros[i] = i + 1;
        pthread_create(&hilos_pasajeros[i], NULL, funcion_pasajero, &Pasajeros[i]);
}
for(int i = 0; i<50; i++) { 
pthread_join(hilos_pasajeros[i], NULL); 
} 
for(int i = 50; i<100; i++) {
    Pasajeros[i] = i+1; 
    pthread_create(&hilos_pasajeros[i], NULL, funcion_pasajero, &Pasajeros[i]);
}
for (int i = 50; i < 100; i++) {
        pthread_join(hilos_pasajeros[i], NULL); 
}
 
for(int i = 0; i<5; i++) {  
pthread_join(hilos_oficinistas[i], NULL);

}

sem_destroy(&cartel); //libero memoria.

return 0; 
}

void* funcion_pasajero(void*arg){ 
 //agrego espera de manera que sea más mezclado. 
int id = *(int *)arg;
sleep(rand() % 3 + 1);
sem_wait(&cartel); 
printf("Pasajero %d esta mirando el cartel\n", id);
sleep(rand() % 3 + 1); 
sem_post(&cartel);  
return NULL; 
}; 

void* funcion_oficinista(void*arg){ 
    int id = *(int* ) arg; 

    for(int i = 0; i<3 ;i++) {
        sem_wait(&cartel); 

    printf("Oficinista %d esta modificando el cartel\n" , id);
    sleep(rand() % 5 + 1);
    sem_post(&cartel);   
    }
    return NULL; 
 
}; 
