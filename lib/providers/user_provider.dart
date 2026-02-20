import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:kangnok/models/roles/user.dart';
import 'package:kangnok/services/user_service.dart';
import 'package:riverpod/riverpod.dart';

///                 Riverpod Provider Chain:
///
///       authStateProvider (Stream from Firebase Auth)
///                         ↓
///     currentUserProvider (watches auth state, fetches from Firestore)
///                         ↓
///     userServiceProvider (the service that talks to Firestore) !!! USE THIS TO GET THE USER MODEL FROM THE CACHED RIVERPOD STATE !!!

/// UserService singleton (talks to Firestore)
final userServiceProvider = Provider<UserService>((ref) => UserService());


/// Streams Firebase Auth state (logged in user or null)
final authStateProvider = StreamProvider<auth.User?>((ref) {
  return auth.FirebaseAuth.instance.authStateChanges();
});


/// Fetches the full User model (Explorer/Ranger) from Firestore
final currentUserProvider = FutureProvider<User?>((ref) async {
  /*
  To use in some widget for example: 

  class SomeWidget extends ConsumerWidget {
    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final userAsync = ref.watch(currentUserProvider); // this line

      return userAsync.when(
        data: (user) {
          if (user == null) return Text('Not logged in');
          if (user is Explorer) return Text('Welcome, ${user.name}');
          if (user is Ranger) return Text('Ranger at ${user.parkId}');
          return Text('Unknown user type');
        },
        loading: () => CircularProgressIndicator(),
        error: (e, _) => Text('Error: $e'),
      );
    }
  }
  */

  final authUser = ref.watch(authStateProvider).value;
  if (authUser == null) return null;

  final userService = ref.read(userServiceProvider);
  return userService.getUser(authUser.uid, email: authUser.email);
});
