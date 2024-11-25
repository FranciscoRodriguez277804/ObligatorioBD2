
use reservas

db.reservas.insertOne({
    
  fechaInicio: new Date("2024-07-01"),
  fechaFin: new Date("2024-07-05"),
  montoReserva: 300.00,
  
  propietario: {
    documento: "12345678",
    nombre: "Juan Pérez",
    telefono: "099123456",
    email: "juan@email.com"
  },
  
  gato: {
    nombre: "Michi",
    raza: "Persa",
    edad: 3,
    peso: 4.5,
    atributos: {
      color: "gris",
      vacunas: [
        { 
          nombre: "Rabia", 
          vencimiento: new Date("2024-12-31") 
        }
      ],
      caracter: "tranquilo",
    },
    foto: {
              nombre:"foto de Michi",
              imagePatch: "~ObligatorioBD2\img\gato-persa-gris.jpg",
              descripcion: "un dia normal para mi gato",
              fecha:new Date("2024-07-01"),
            }
    
  },
  
  habitacion: {
    nombre: "Suite1",
    capacidad: 2,
    precio: 100.00,
    estado: "DISPONIBLE"
  },
  
  servicios: [
    {
      nombre: "PELUQUERIA",
      precio: 50.00,
      cantidad: 1,
      detalles: {
        estilista: "Ana",
        tipoCorte: "León"
      }
    }
  ]
})


db.reservas.insertMany([
  {
    fechaInicio: new Date("2024-07-10"),
    fechaFin: new Date("2024-07-15"),
    montoReserva: 250.00,
    propietario: {
      documento: "87654321",
      nombre: "María García",
      telefono: "098765432",
      email: "maria@email.com"
    },
    gato: {
      nombre: "Luna",
      raza: "Siamés",
      edad: 2,
      peso: 3.5,
      atributos: {
        alergias: ["pescado"],
        comportamiento: "juguetón"
      }
      
    },
    habitacion: {
      nombre: "Suite2",
      capacidad: 1,
      precio: 80.00,
      estado: "LLENA"
    },
    servicios: [
      {
        nombre: "CONTROL_PARASITOS",
        precio: 30.00,
        cantidad: 1
      }
    ]
  },
  {
    fechaInicio: new Date("2024-07-20"),
    fechaFin: new Date("2024-07-25"),
    montoReserva: 400.00,
    propietario: {
      documento: "12345678", // Mismo propietario que la primera reserva
      nombre: "Juan Pérez",
      telefono: "099123456",
      email: "juan@email.com"
    },
    gato: {
      nombre: "Pelusa", // Otro gato del mismo propietario
      raza: "Maine Coon",
      edad: 4,
      peso: 6.0,
      atributos: {
        color: "naranja",
        necesidadesEspeciales: ["dieta especial"]
      }
    },
    habitacion: {
      nombre: "Suite3",
      capacidad: 2,
      precio: 120.00,
      estado: "LLENA"
    },
    servicios: [
      {
        nombre: "PELUQUERIA",
        precio: 50.00,
        cantidad: 1
      },
      {
        nombre: "REVISION_VETERINARIA",
        precio: 70.00,
        cantidad: 1
      }
    ]
  }
])

db.reservas.find()

//B. Listar reservas del propietario con documento "12345678" 

db.reservas.find({ "propietario.documento": "12345678" });

//C. Listar las reservas que incluyen el servicio "PELUQUERIA ".

db.reservas.find({"servicios.nombre": "PELUQUERIA"})

//D. Actualizar el estado de la habitación "Suite1" asegurándose que está en estado "DISPONIBLE"
//y pasándolo a estado "LLENA".

db.reservas.updateOne(
    {
        "habitacion.nombre": "Suite1",
        "habitacion.estado":"DISPONIBLE"
        
    },
    {
        $set: {"habitacion.estado": "LLENA"}
    }
)

//E. Listar nombre de propietario y cantidad de reservas con fecha de inicio en julio 2024, para los
//propietarios que tengan más de una reserva en ese mes. 

db.reservas.aggregate([
  {
    //filtador de documentos 
    $match: {
      fechaInicio: {
        $gte: ISODate("2024-07-01"), //menor o igual a 
        $lt: ISODate("2024-08-01")  // mayor que 
      }
    }
  },
  {
    $group: {
      _id: "$propietario.documento", //agrupar documentos 
      nombrePropietario: { $first: "$propietario.nombre" }, //Encuentra el primer valor 
      cantidadReservas: { $sum: 1 } //cuanta cuantos documentos hay en cada grupo , por cada documento en el grupo se suma 1 
    }
  },
  {
    $match: {
      cantidadReservas: { $gt: 1 } //mayor a uno 
    }
  },
  {
    $project: {
      _id: 0, //Excluye el campo id 
      nombrePropietario: 1, //incluye el campo 
      cantidadReservas: 1 // incluye el campo 
    }
  }
])
  




