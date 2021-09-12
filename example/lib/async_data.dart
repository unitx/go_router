import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'shared/data.dart';
import 'shared/pages.dart';

void main() => runApp(App());

/// sample app using the path URL strategy, i.e. no # in the URL path
class App extends StatelessWidget {
  final repo = Repository();
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
        title: 'Async Data GoRouter Example',
      );

  late final _router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: FutureBuilder<List<Family>>(
            future: repo.getFamilies(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text(snapshot.error.toString());
              if (snapshot.hasData) return HomePage(families: snapshot.data!);
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        routes: [
          GoRoute(
            path: 'family/:fid',
            builder: (context, state) => MaterialPage<void>(
              key: state.pageKey,
              child: FutureBuilder<Family>(
                future: repo.getFamily(state.params['fid']!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return Text(snapshot.error.toString());
                  if (snapshot.hasData)
                    return FamilyPage(family: snapshot.data!);
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            routes: [
              GoRoute(
                path: 'person/:pid',
                builder: (context, state) => MaterialPage<void>(
                  key: state.pageKey,
                  child: FutureBuilder<FamilyPerson>(
                    future: repo.getPerson(
                      state.params['fid']!,
                      state.params['pid']!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError)
                        return Text(snapshot.error.toString());
                      if (snapshot.hasData)
                        return PersonPage(
                            family: snapshot.data!.family,
                            person: snapshot.data!.person);
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
    error: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: ErrorPage(state.error),
    ),
  );
}
