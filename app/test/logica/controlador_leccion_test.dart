import 'package:flutter_test/flutter_test.dart';
import 'package:sabermovil/datos/modelos/modelos.dart';
import 'package:sabermovil/logica/controlador_leccion.dart';

void main() {
  const leccion = Leccion(
    id: 'l1',
    unidadId: 'u1',
    titulo: 'Fracciones',
    orden: 1,
    texto: 'Una fracción es una parte de un todo.',
    ejercicios: [
      Ejercicio(
        id: 'e1',
        pregunta: '¿Cuánto es 1/2?',
        opciones: ['Mitad', 'Tercio'],
        correcta: 0,
      ),
      Ejercicio(
        id: 'e2',
        pregunta: '¿Cuánto es 2/4?',
        opciones: ['Un cuarto', 'Mitad'],
        correcta: 1,
      ),
    ],
  );

  test('empieza en la primera pregunta sin responder', () {
    final controlador = ControladorLeccion(leccion);

    expect(controlador.indice, 0);
    expect(controlador.aciertos, 0);
    expect(controlador.respondida, isFalse);
    expect(controlador.esUltima, isFalse);
    expect(controlador.total, 2);
  });

  test('responde bien y avanza sin duplicar intentos', () {
    final controlador = ControladorLeccion(leccion);

    controlador.responder(0);
    controlador.responder(0); // segundo toque, se ignora
    expect(controlador.aciertos, 1);
    expect(controlador.respondida, isTrue);

    controlador.siguiente();
    expect(controlador.indice, 1);
    expect(controlador.respondida, isFalse);
  });

  test('cuenta mal las respuestas incorrectas', () {
    final controlador = ControladorLeccion(leccion);

    controlador.responder(1); // incorrecta
    expect(controlador.aciertos, 0);
  });

  test('llega a la última pregunta', () {
    final controlador = ControladorLeccion(leccion);

    controlador.responder(0);
    controlador.siguiente();
    expect(controlador.esUltima, isTrue);
  });
}
