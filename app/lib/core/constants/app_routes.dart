class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  
  // Adoptante
  static const String adoptanteHome = '/adoptante';
  static const String questionnaire = '/adoptante/cuestionario';
  static const String matchingResults = '/adoptante/resultados';
  static const String petDetail = '/adoptante/pet/:id';
  static const String foundationDetail = '/adoptante/foundation/:id';
  static const String adoptionRequest = '/adoptante/solicitud/:id';
  static const String chat = '/adoptante/chat/:petId/:userId';
  static const String myAdoptions = '/adoptante/adopciones';
  static const String careAlerts = '/adoptante/alertas';
  static const String guides = '/adoptante/guias';
  static const String anonymousReport = '/adoptante/reportar';

  // Coordinador de Fundación
  static const String coordinadorHome = '/coordinador';
  static const String petManagement = '/coordinador/animales';
  static const String receivedRequests = '/coordinador/solicitudes';
  static const String analytics = '/coordinador/analiticas';
  static const String campaignManagement = '/coordinador/campanas';
  static const String campaignVolunteers = '/coordinador/voluntarios/:id';

  // Voluntario
  static const String voluntarioHome = '/voluntario';
  static const String campaignDetail = '/voluntario/campana/:id';
  static const String volunteerProfile = '/voluntario/perfil';
  static const String volunteerHistory = '/voluntario/historial';
  static const String volunteerCertificate = '/voluntario/certificado';

  // Administrador
  static const String adminHome = '/admin';
  static const String verifyFoundations = '/admin/verificaciones';
  static const String systemConfig = '/admin/configuracion';
}
