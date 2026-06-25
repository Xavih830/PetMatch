import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { 
  Heart, 
  Smartphone, 
  Users, 
  ShieldAlert, 
  CheckCircle2, 
  Clock, 
  MessageSquare, 
  Calendar, 
  FileText, 
  Download, 
  Award, 
  BarChart3, 
  Layers, 
  MapPin, 
  UserCheck,
  ChevronRight,
  TrendingUp,
  FileBadge
} from 'lucide-react';
import logo from './assets/logo.svg';

export default function App() {
  const [activeTab, setActiveTab] = useState('adoptante');

  const containerVariants = {
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: {
        staggerChildren: 0.2
      }
    }
  };

  const itemVariants = {
    hidden: { y: 30, opacity: 0 },
    visible: { y: 0, opacity: 1, transition: { duration: 0.6, ease: "easeOut" } }
  };

  const tabsData = {
    adoptante: {
      title: "Para el Adoptante",
      desc: "Encuentra tu compañero ideal sin dejar nada a la suerte. PetMatch te acompaña desde el primer match hasta el cuidado diario.",
      features: [
        "Cuestionario de compatibilidad sobre estilo de vida y vivienda.",
        "Algoritmo de matching inteligente con puntaje de compatibilidad en %.",
        "Chat directo con la fundación del animal de forma segura.",
        "Calendario de alertas de cuidado (vacunas, chequeos, alimentación).",
        "Guías interactivas para una tenencia responsable."
      ],
      color: "border-primary text-primary"
    },
    fundacion: {
      title: "Para las Fundaciones",
      desc: "Digitaliza tu gestión, centraliza tus solicitudes y automatiza la validación de adoptantes para liberar tiempo valioso de rescate.",
      features: [
        "Dashboard interactivo con animales, solicitudes y donaciones.",
        "Gestión digital de fichas médicas, fotos y temperamentos.",
        "Filtro automático de solicitudes según perfil de adoptabilidad.",
        "Panel de coordinación de campañas de voluntariado y cupos.",
        "Gráficos mensuales de recaudaciones y reportes analíticos."
      ],
      color: "border-secondary text-secondary"
    },
    voluntario: {
      title: "Para los Voluntarios",
      desc: "Conecta con fundaciones que necesitan tus manos. Suma horas de valor, desbloquea insignias y obtén tu certificado digital.",
      features: [
        "Buscador de campañas locales filtrado por tipo de actividad.",
        "Sistema de inscripción rápida con selección de horario.",
        "Historial acumulado de campañas y horas apoyadas.",
        "Insignias y racha activa para celebrar tus logros.",
        "Generador de certificado digital en formato PDF con firma institucional."
      ],
      color: "border-teal-500 text-teal-600"
    },
    administrador: {
      title: "Para el Administrador",
      desc: "Supervisa todo el ecosistema de adopción, aprueba fundaciones verificadas y gestiona los reportes de ayuda comunitaria.",
      features: [
        "Panel de verificación de fundaciones con revisión de credenciales.",
        "Gestión de denuncias anónimas geolocalizadas por maltrato o abandono.",
        "Configuración global del sistema (tasas de donación, correos de envío).",
        "Control y auditoría de usuarios y registros del sistema."
      ],
      color: "border-slate-700 text-slate-700"
    }
  };

  return (
    <div className="min-h-screen bg-crema text-carbon selection:bg-primary/20 select-none">
      
      {/* Navigation */}
      <nav className="sticky top-0 z-50 bg-crema/80 backdrop-blur-md border-b border-primary/10 px-6 py-4 transition-all duration-300">
        <div className="max-w-7xl mx-auto flex items-center justify-between">
          <a href="#" className="flex items-center gap-3">
            <img src={logo} alt="PetMatch Logo" className="h-10 w-10 animate-pulse" />
            <span className="text-2xl font-extrabold tracking-tight">
              <span className="text-primary">Pet</span>
              <span className="text-secondary">Match</span>
            </span>
          </a>
          
          <div className="hidden md:flex items-center gap-8 font-medium">
            <a href="#problema" className="text-carbon hover:text-primary transition-colors">El Problema</a>
            <a href="#funcionamiento" className="text-carbon hover:text-primary transition-colors">Cómo Funciona</a>
            <a href="#roles" className="text-carbon hover:text-primary transition-colors">Roles</a>
            <a href="#caracteristicas" className="text-carbon hover:text-primary transition-colors">Características</a>
            <a href="#descarga" className="text-carbon hover:text-primary transition-colors">Descarga</a>
            <a href="/PetMatch/app/" className="text-secondary font-bold hover:text-[#e1520b] transition-colors">Probar Versión Web</a>
          </div>

          <a 
            href="https://github.com/Xavih830/PetMatch/releases" 
            target="_blank" 
            rel="noopener noreferrer"
            className="bg-primary hover:bg-primary-dark text-white font-semibold px-5 py-2.5 rounded-full shadow-lg shadow-primary/20 hover:shadow-primary/40 transform hover:-translate-y-0.5 transition-all flex items-center gap-2"
          >
            <Download size={18} />
            <span>Descargar APK</span>
          </a>
        </div>
      </nav>

      {/* Hero Section */}
      <section className="relative overflow-hidden pt-12 pb-24 px-6">
        {/* Decorative Gradients */}
        <div className="absolute top-[-20%] left-[-10%] w-[500px] h-[500px] bg-primary/10 rounded-full blur-3xl pointer-events-none" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[500px] h-[500px] bg-secondary/10 rounded-full blur-3xl pointer-events-none" />

        <div className="max-w-7xl mx-auto grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
          <motion.div 
            className="lg:col-span-7 flex flex-col justify-center text-left"
            initial={{ opacity: 0, x: -50 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ duration: 0.8 }}
          >
            <span className="text-primary font-bold text-sm tracking-widest uppercase mb-4 inline-flex items-center gap-2 bg-primary/10 px-4 py-1.5 rounded-full w-fit">
              <Heart className="fill-primary" size={14} /> ¡El amor no es al azar!
            </span>
            <h1 className="text-4xl md:text-6xl font-extrabold tracking-tight text-carbon leading-tight mb-6">
              Encuentra a tu compañero ideal con un <span className="text-primary relative inline-block">Match<span className="absolute bottom-1 left-0 w-full h-2 bg-secondary/30 -z-10" /></span>
            </h1>
            <p className="text-lg md:text-xl text-carbon/80 leading-relaxed mb-8">
              PetMatch es la primera plataforma de adopción responsable en Guayaquil estructurada con un **algoritmo de compatibilidad**. Evaluamos tu estilo de vida para conectarte de forma inteligente y segura con tu mascota ideal.
            </p>
            <div className="flex flex-wrap gap-4">
              <a 
                href="/PetMatch/app/"
                className="bg-secondary hover:bg-[#e1520b] text-white font-bold px-8 py-4 rounded-full shadow-xl shadow-secondary/30 flex items-center gap-3 transition-all transform hover:-translate-y-1"
              >
                <Smartphone size={20} />
                <span>Probar Versión Web</span>
              </a>
              <a 
                href="#descarga"
                className="border-2 border-primary text-primary hover:bg-primary hover:text-white font-bold px-8 py-4 rounded-full flex items-center gap-2 transition-all transform hover:-translate-y-1"
              >
                <span>Descargar APK</span>
                <Download size={20} />
              </a>
            </div>
          </motion.div>

          {/* Interactive CSS Phone Mockup */}
          <motion.div 
            className="lg:col-span-5 flex justify-center"
            initial={{ opacity: 0, y: 50 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            <div className="relative w-[300px] h-[610px] bg-slate-900 rounded-[50px] border-[10px] border-slate-800 shadow-2xl p-3 flex flex-col justify-between overflow-hidden">
              {/* Speaker and Camera Notch */}
              <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-40 h-6 bg-slate-800 rounded-b-2xl z-20 flex justify-center items-center gap-2">
                <div className="w-12 h-1 bg-slate-700 rounded-full" />
                <div className="w-2.5 h-2.5 bg-slate-900 rounded-full" />
              </div>

              {/* App Content */}
              <div className="w-full h-full bg-[#FDF8F2] rounded-[38px] overflow-hidden flex flex-col relative z-10 pt-6">
                {/* Simulated App Header */}
                <div className="px-4 py-2 flex justify-between items-center bg-[#FDF8F2] border-b border-gray-100">
                  <div className="flex items-center gap-1.5">
                    <img src={logo} className="h-6 w-6" alt="logo" />
                    <span className="font-extrabold text-sm tracking-tight"><span className="text-primary">Pet</span><span className="text-secondary">Match</span></span>
                  </div>
                  <span className="text-xs bg-emerald-100 text-emerald-800 font-bold px-2 py-0.5 rounded-full">Fase 1</span>
                </div>

                {/* Discovery Card Simulated Screen */}
                <div className="flex-1 p-3 flex flex-col justify-center">
                  <div className="bg-white rounded-3xl shadow-md border border-gray-100 overflow-hidden flex-1 flex flex-col max-h-[380px]">
                    <div className="relative flex-1 bg-slate-200">
                      {/* Placeholder Dog Picture using CSS Patterns & Color */}
                      <div className="absolute inset-0 bg-gradient-to-tr from-orange-400 to-amber-200 flex items-center justify-center">
                        <Heart className="text-white/80 w-16 h-16 animate-bounce" />
                      </div>
                      
                      {/* Compatibility Badge */}
                      <div className="absolute top-3 right-3 bg-secondary text-white font-extrabold text-xs px-3 py-1.5 rounded-full shadow flex items-center gap-1">
                        <TrendingUp size={12} />
                        95% Match
                      </div>
                    </div>
                    <div className="p-4 text-left">
                      <h3 className="font-extrabold text-lg text-carbon">Max, 2 años</h3>
                      <p className="text-xs text-gray-500 mb-2">Golden Retriever • Guayaquil Norte</p>
                      
                      <div className="flex flex-wrap gap-1.5 mb-3">
                        <span className="text-[10px] bg-crema text-carbon font-medium px-2 py-0.5 rounded">Juguetón</span>
                        <span className="text-[10px] bg-crema text-carbon font-medium px-2 py-0.5 rounded">Apto para Niños</span>
                      </div>
                      
                      <button className="w-full bg-primary text-white font-bold py-2 rounded-xl text-xs flex items-center justify-center gap-1 shadow-md shadow-primary/20">
                        <Heart size={12} className="fill-white" />
                        Adoptar Responsablemente
                      </button>
                    </div>
                  </div>
                </div>

                {/* Simulated Bottom Navigation */}
                <div className="bg-white border-t border-gray-100 px-4 py-2.5 flex justify-between items-center text-gray-400">
                  <Heart className="text-primary fill-primary" size={20} />
                  <MessageSquare size={20} />
                  <Calendar size={20} />
                  <Award size={20} />
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* The Problem Section */}
      <section id="problema" className="py-20 bg-white px-6">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-carbon mb-4">
            La adopción tradicional es compleja
          </h2>
          <p className="text-lg text-carbon/75 max-w-2xl mx-auto mb-16">
            Actualmente, los procesos de adopción se gestionan de forma fragmentada, lenta y sin criterios claros de afinidad, lo que puede provocar abandonos o procesos frustrantes.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="bg-crema p-8 rounded-3xl border border-primary/5 shadow-sm flex flex-col items-center hover:shadow-md transition-all">
              <div className="h-16 w-16 bg-primary/10 rounded-full flex items-center justify-center mb-6 text-primary">
                <Smartphone size={32} />
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Incertidumbre Adoptante</h3>
              <p className="text-sm text-carbon/70 text-center leading-relaxed">
                Falta de claridad sobre si el temperamento, nivel de energía o espacio que requiere una mascota se alinea realmente con su estilo de vida cotidiano.
              </p>
            </div>

            <div className="bg-crema p-8 rounded-3xl border border-primary/5 shadow-sm flex flex-col items-center hover:shadow-md transition-all">
              <div className="h-16 w-16 bg-secondary/10 rounded-full flex items-center justify-center mb-6 text-secondary">
                <Users size={32} />
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Sobrecarga en Fundaciones</h3>
              <p className="text-sm text-carbon/70 text-center leading-relaxed">
                Coordinadores abrumados atendiendo solicitudes manuales repetitivas en WhatsApp, perdiendo tiempo que podrían destinar a rescates en campo.
              </p>
            </div>

            <div className="bg-crema p-8 rounded-3xl border border-primary/5 shadow-sm flex flex-col items-center hover:shadow-md transition-all">
              <div className="h-16 w-16 bg-amber-500/10 rounded-full flex items-center justify-center mb-6 text-amber-600">
                <ShieldAlert size={32} />
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Desconexión Voluntaria</h3>
              <p className="text-sm text-carbon/70 text-center leading-relaxed">
                Dificultad para coordinar turnos en campañas de alimentación y baño, y ausencia de incentivos visibles por el tiempo dedicado al voluntariado.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="funcionamiento" className="py-20 px-6 bg-crema">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-carbon mb-4">
            ¿Cómo funciona el Matching?
          </h2>
          <p className="text-lg text-carbon/75 max-w-2xl mx-auto mb-16">
            Simplificamos el camino hacia una adopción responsable en tres pasos asistidos por tecnología.
          </p>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12 relative">
            {/* Visual connector line for large screens */}
            <div className="hidden lg:block absolute top-1/4 left-[15%] right-[15%] h-0.5 bg-gradient-to-r from-primary to-secondary -z-10" />

            <div className="flex flex-col items-center">
              <div className="h-14 w-14 bg-primary text-white font-extrabold text-xl rounded-full flex items-center justify-center shadow-lg shadow-primary/20 mb-6">
                1
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Completa tu perfil</h3>
              <p className="text-sm text-carbon/70 max-w-sm">
                Responde un breve cuestionario sobre tus horas fuera de casa, tipo de vivienda, presencia de niños y experiencia previa.
              </p>
            </div>

            <div className="flex flex-col items-center">
              <div className="h-14 w-14 bg-secondary text-white font-extrabold text-xl rounded-full flex items-center justify-center shadow-lg shadow-secondary/20 mb-6">
                2
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Recibe tus Matches</h3>
              <p className="text-sm text-carbon/70 max-w-sm">
                Nuestro algoritmo local evalúa y ordena el catálogo de mascotas de forma instantánea de 0% a 100% de compatibilidad.
              </p>
            </div>

            <div className="flex flex-col items-center">
              <div className="h-14 w-14 bg-slate-800 text-white font-extrabold text-xl rounded-full flex items-center justify-center shadow-lg shadow-slate-800/20 mb-6">
                3
              </div>
              <h3 className="text-xl font-bold text-carbon mb-3">Inicia la Adopción</h3>
              <p className="text-sm text-carbon/70 max-w-sm">
                Conéctate por el chat seguro, agenda visitas y recibe notificaciones programadas de cuidado para vacunas y chequeos.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Tabs Roles Section */}
      <section id="roles" className="py-20 bg-white px-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-carbon mb-4">
              Una solución para cada rol
            </h2>
            <p className="text-lg text-carbon/75 max-w-2xl mx-auto">
              PetMatch integra a todos los actores clave del ecosistema de bienestar animal en una sola aplicación interactiva.
            </p>
          </div>

          {/* Tab buttons */}
          <div className="flex flex-wrap justify-center gap-3 mb-10 border-b border-gray-100 pb-6">
            {Object.keys(tabsData).map((tabKey) => (
              <button
                key={tabKey}
                onClick={() => setActiveTab(tabKey)}
                className={`px-6 py-3 rounded-full font-bold text-sm transition-all uppercase tracking-wider ${
                  activeTab === tabKey
                    ? 'bg-carbon text-white shadow-md'
                    : 'bg-crema text-carbon/60 hover:bg-gray-150'
                }`}
              >
                {tabsData[tabKey].title.replace("Para el ", "").replace("Para las ", "").replace("Para los ", "")}
              </button>
            ))}
          </div>

          {/* Tab content */}
          <div className="bg-crema rounded-3xl p-8 md:p-12 border border-primary/5 shadow-sm max-w-4xl mx-auto">
            <AnimatePresence mode="wait">
              <motion.div
                key={activeTab}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -15 }}
                transition={{ duration: 0.3 }}
                className="grid grid-cols-1 md:grid-cols-12 gap-8 items-center"
              >
                <div className="md:col-span-7 text-left">
                  <span className="text-xs uppercase tracking-widest font-extrabold text-primary mb-2 block">
                    {tabsData[activeTab].title}
                  </span>
                  <h3 className="text-2xl md:text-3xl font-extrabold text-carbon mb-4">
                    {tabsData[activeTab].title}
                  </h3>
                  <p className="text-sm md:text-base text-carbon/80 leading-relaxed mb-6">
                    {tabsData[activeTab].desc}
                  </p>
                  <ul className="space-y-3">
                    {tabsData[activeTab].features.map((feat, index) => (
                      <li key={index} className="flex items-start gap-2.5 text-xs md:text-sm text-carbon/75">
                        <CheckCircle2 className="text-secondary shrink-0 mt-0.5" size={16} />
                        <span>{feat}</span>
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="md:col-span-5 flex justify-center">
                  {/* Decorative representation of the interface */}
                  <div className="relative bg-white p-6 rounded-3xl shadow-lg border border-gray-100 w-full max-w-[280px]">
                    <div className={`border-t-4 ${tabsData[activeTab].color} pt-4 text-left`}>
                      <span className="text-[10px] font-bold text-gray-400">PETMATCH DASHBOARD</span>
                      <h4 className="font-extrabold text-carbon text-lg mt-1 mb-3">Módulo de {activeTab}</h4>
                      
                      {activeTab === 'adoptante' && (
                        <div className="space-y-2.5">
                          <div className="h-2 w-full bg-slate-100 rounded" />
                          <div className="h-2 w-5/6 bg-slate-100 rounded" />
                          <div className="h-8 w-full bg-primary/10 rounded-xl flex items-center justify-between px-3 mt-4 text-[10px] font-bold text-primary">
                            <span>Compatibilidad</span>
                            <span>95% Match</span>
                          </div>
                        </div>
                      )}

                      {activeTab === 'fundacion' && (
                        <div className="space-y-3">
                          <div className="flex justify-between items-center text-[10px] bg-secondary/15 p-2 rounded-lg text-secondary font-bold">
                            <span>Solicitudes Recibidas</span>
                            <span>3 Nuevas</span>
                          </div>
                          {/* Tiny Bar graph simulation */}
                          <div className="flex gap-1.5 items-end justify-between h-12 pt-4">
                            <div className="w-4 bg-[#2EC4B6] h-6 rounded-t" />
                            <div className="w-4 bg-[#F26419] h-10 rounded-t" />
                            <div className="w-4 bg-[#2EC4B6] h-4 rounded-t" />
                            <div className="w-4 bg-[#F26419] h-8 rounded-t" />
                          </div>
                        </div>
                      )}

                      {activeTab === 'voluntario' && (
                        <div className="space-y-3">
                          <div className="flex items-center gap-2 bg-emerald-50 border border-emerald-200 p-2.5 rounded-xl">
                            <FileBadge size={20} className="text-emerald-600" />
                            <div>
                              <div className="text-[9px] font-bold text-emerald-800">Insignia Activada</div>
                              <div className="text-[8px] text-emerald-700">Rescatista Estrella</div>
                            </div>
                          </div>
                          <div className="bg-slate-50 p-2 rounded-xl text-[10px] text-center font-bold text-slate-700 flex items-center justify-center gap-1">
                            <FileText size={10} />
                            Generar Certificado PDF
                          </div>
                        </div>
                      )}

                      {activeTab === 'administrador' && (
                        <div className="space-y-2">
                          <div className="p-2 bg-rose-50 border border-rose-200 rounded-lg text-[9px] text-rose-800 flex justify-between items-center font-bold">
                            <span>Denuncia de Abandono</span>
                            <span className="bg-rose-600 text-white px-1.5 py-0.5 rounded text-[8px]">Grave</span>
                          </div>
                          <div className="h-2 w-full bg-slate-100 rounded mt-4" />
                          <div className="h-2 w-3/4 bg-slate-100 rounded" />
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              </motion.div>
            </AnimatePresence>
          </div>
        </div>
      </section>

      {/* Grid Features Section */}
      <section id="caracteristicas" className="py-20 bg-crema px-6">
        <div className="max-w-7xl mx-auto text-center">
          <h2 className="text-3xl md:text-5xl font-extrabold tracking-tight text-carbon mb-4">
            Características destacadas
          </h2>
          <p className="text-lg text-carbon/75 max-w-2xl mx-auto mb-16">
            Diseñamos cada función pensando en brindar una experiencia segura y sin fricciones para ti y las mascotas.
          </p>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-primary/10 rounded-2xl flex items-center justify-center text-primary mb-6">
                <Heart size={24} className="fill-primary/20" />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Matching Inteligente</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Algoritmo integrado que cruza estilo de vida del adoptante con el temperamento, raza y nivel de actividad física de la mascota.
              </p>
            </div>

            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-secondary/10 rounded-2xl flex items-center justify-center text-secondary mb-6">
                <FileText size={24} />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Historial Médico</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Consulta de forma clara y centralizada las vacunas aplicadas, desparasitaciones pendientes y el estado general de salud del animal.
              </p>
            </div>

            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-teal-500/10 rounded-2xl flex items-center justify-center text-teal-600 mb-6">
                <Calendar size={24} />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Voluntariado con Cupos</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Explora campañas locales, inscríbete y selecciona tus habilidades para apoyar en actividades de baño, paseo o rescate.
              </p>
            </div>

            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-emerald-500/10 rounded-2xl flex items-center justify-center text-emerald-600 mb-6">
                <Award size={24} />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Gamificación y Racha</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Participa de forma continua en campañas, gana insignias desbloqueables por logros y mantén tu racha de voluntariado activa.
              </p>
            </div>

            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-rose-500/10 rounded-2xl flex items-center justify-center text-rose-600 mb-6">
                <ShieldAlert size={24} />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Denuncias Anónimas</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Reporta de forma anónima incidentes de maltrato o abandono especificando el tipo, zona y descripción para que el admin actúe.
              </p>
            </div>

            <div className="bg-white p-8 rounded-3xl border border-gray-150 text-left hover:shadow-md transition-all">
              <div className="h-12 w-12 bg-amber-500/10 rounded-2xl flex items-center justify-center text-amber-600 mb-6">
                <BarChart3 size={24} />
              </div>
              <h3 className="text-lg font-bold text-carbon mb-2">Analíticas en Tiempo Real</h3>
              <p className="text-xs md:text-sm text-carbon/70 leading-relaxed">
                Gráficas mensuales del rendimiento financiero de donaciones de fundaciones y distribución estadística de las zonas de mayor abandono.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Download Section */}
      <section id="descarga" className="py-20 bg-white px-6 relative overflow-hidden">
        <div className="max-w-4xl mx-auto bg-gradient-to-tr from-primary to-primary-light text-white rounded-3xl p-8 md:p-16 text-center shadow-xl shadow-primary/20 relative z-10">
          <div className="absolute top-0 right-0 w-32 h-32 bg-white/5 rounded-full blur-xl pointer-events-none" />
          
          <h2 className="text-3xl md:text-5xl font-extrabold mb-6 leading-tight">
            ¿Listo para cambiar una vida?
          </h2>
          <p className="text-white/80 max-w-xl mx-auto mb-10 text-sm md:text-base leading-relaxed">
            Descarga la aplicación móvil de PetMatch para Android y accede al emparejamiento con mascotas que realmente se adapten a tu estilo de vida.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-6">
            <a 
              href="https://github.com/Xavih830/PetMatch/releases" 
              target="_blank" 
              rel="noopener noreferrer"
              className="bg-white text-primary hover:bg-crema font-bold px-8 py-4 rounded-full flex items-center gap-3 transition-all transform hover:-translate-y-1 shadow-lg w-full sm:w-auto justify-center"
            >
              <Download size={20} />
              <span>Descargar APK (Android)</span>
            </a>
            
            {/* Visual QR Simulation */}
            <div className="bg-white/10 backdrop-blur-sm border border-white/20 p-4 rounded-2xl flex items-center gap-4 text-left w-full sm:w-auto">
              <div className="bg-white p-2.5 rounded-xl shrink-0">
                {/* Visual grid simulated QR using SVG */}
                <svg width="60" height="60" viewBox="0 0 60 60" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M0 0H20V20H0V0ZM4 4V16H16V4H4Z" fill="#2D2D2D" />
                  <path d="M40 0H60V20H40V0ZM44 4V16H56V4H44Z" fill="#2D2D2D" />
                  <path d="M0 40H20V60H0V40ZM4 44V56H16V44H4Z" fill="#2D2D2D" />
                  <rect x="8" y="8" width="4" height="4" fill="#2D2D2D" />
                  <rect x="48" y="8" width="4" height="4" fill="#2D2D2D" />
                  <rect x="8" y="48" width="4" height="4" fill="#2D2D2D" />
                  <path d="M26 4H30V8H26V4Z" fill="#2D2D2D" />
                  <path d="M34 4H38V12H34V4Z" fill="#2D2D2D" />
                  <path d="M26 12H30V20H26V12Z" fill="#2D2D2D" />
                  <path d="M4 26H12V30H4V26Z" fill="#2D2D2D" />
                  <path d="M16 26H20V34H16V26Z" fill="#2D2D2D" />
                  <path d="M26 26H34V30H26V26Z" fill="#2D2D2D" />
                  <path d="M38 26H48V30H38V26Z" fill="#2D2D2D" />
                  <path d="M52 26H56V38H52V26Z" fill="#2D2D2D" />
                  <path d="M26 34H30V38H26V34Z" fill="#2D2D2D" />
                  <path d="M34 34H44V38H34V34Z" fill="#2D2D2D" />
                  <path d="M48 34H50V38H48V34Z" fill="#2D2D2D" />
                  <path d="M26 44H38V48H26V44Z" fill="#2D2D2D" />
                  <path d="M42 44H56V48H42V44Z" fill="#2D2D2D" />
                  <path d="M26 52H30V56H26V52Z" fill="#2D2D2D" />
                  <path d="M34 52H48V56H34V52Z" fill="#2D2D2D" />
                  <path d="M52 52H56V60H52V52Z" fill="#2D2D2D" />
                </svg>
              </div>
              <div className="text-white">
                <div className="text-xs font-bold">Escanea el QR</div>
                <div className="text-[10px] opacity-80 leading-snug mt-0.5">Descarga directa en tu celular de forma inmediata.</div>
              </div>
            </div>
          </div>

          <div className="mt-10 pt-8 border-t border-white/20 text-left text-xs text-white/80 space-y-2">
            <h4 className="font-bold text-sm text-white">Instrucciones de Instalación en Android:</h4>
            <ol className="list-decimal list-inside space-y-1">
              <li>Haz clic en <strong>Descargar APK</strong> o escanea el código QR desde tu celular.</li>
              <li>Abre el archivo descargado. Si Android te lo solicita, activa la casilla <strong>"Permitir desde esta fuente"</strong> en los ajustes de seguridad del navegador.</li>
              <li>Toca en <strong>Instalar</strong> y ¡listo! Abre la aplicación PetMatch.</li>
              <li>Inicia sesión usando alguna de las credenciales de prueba descritas al final de esta página.</li>
            </ol>
          </div>
        </div>
      </section>

      {/* Footer Section */}
      <footer className="bg-carbon text-white pt-16 pb-8 px-6 text-center border-t-8 border-primary">
        <div className="max-w-7xl mx-auto">
          <div className="flex flex-col items-center mb-8">
            <div className="flex items-center gap-3 mb-4">
              {/* White inverted version of the logo */}
              <div className="bg-white p-2 rounded-2xl h-10 w-10 flex items-center justify-center">
                <Heart className="text-primary fill-primary" size={24} />
              </div>
              <span className="text-2xl font-extrabold tracking-tight">
                <span className="text-white">Pet</span>
                <span className="text-secondary">Match</span>
              </span>
            </div>
            <p className="text-sm text-gray-400 max-w-sm">
              Conectando corazones en Guayaquil a través del emparejamiento inteligente de mascotas.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8 py-8 border-t border-white/10 text-left text-xs md:text-sm text-gray-400">
            <div>
              <h4 className="font-bold text-white mb-3">Integrantes del Equipo (ESPOL):</h4>
              <ul className="space-y-1">
                <li>Alay Mosquera Diego Javier</li>
                <li>Angulo Borja Hilda Victoria</li>
                <li>Camacho Galarza Xavier Homero</li>
                <li>Dominguez Gómez César Marcelo</li>
                <li>Montes Muñoz Cecilia Inés</li>
                <li>Sandoval Malla Anggie Nicole</li>
                <li>Sierra De Janón Nicolás Alejandro</li>
              </ul>
            </div>
            <div>
              <h4 className="font-bold text-white mb-3">Materia y Contexto:</h4>
              <ul className="space-y-1 leading-relaxed">
                <li>Sistemas de Información, CCPG1054</li>
                <li>I PAO 2026, ESPOL</li>
                <li>
                  <strong>Credenciales Demo:</strong>
                  <ul className="list-disc list-inside mt-2 space-y-0.5 text-gray-400 text-xs">
                    <li>Adoptante: <code className="bg-white/10 px-1 py-0.5 rounded">valentina@petmatch.ec</code> / <code className="bg-white/10 px-1 py-0.5 rounded">petmatch123</code></li>
                    <li>Fundación: <code className="bg-white/10 px-1 py-0.5 rounded">roberto@huellitas.ec</code> / <code className="bg-white/10 px-1 py-0.5 rounded">petmatch123</code></li>
                    <li>Voluntario: <code className="bg-white/10 px-1 py-0.5 rounded">sebastian@petmatch.ec</code> / <code className="bg-white/10 px-1 py-0.5 rounded">petmatch123</code></li>
                    <li>Administrador: <code className="bg-white/10 px-1 py-0.5 rounded">admin@petmatch.ec</code> / <code className="bg-white/10 px-1 py-0.5 rounded">admin2026</code></li>
                  </ul>
                </li>
              </ul>
            </div>
          </div>

          <div className="pt-8 border-t border-white/10 text-xs text-gray-500">
            &copy; {new Date().getFullYear()} PetMatch v2.0. Desarrollado con fines académicos. Todos los derechos reservados.
          </div>
        </div>
      </footer>
    </div>
  );
}
